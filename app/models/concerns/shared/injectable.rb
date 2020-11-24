module Shared::Injectable
  extend ActiveSupport::Concern

  RESPONSE_REGEX = /\[question id=("|'|‘)([0-9]+)("|'|’)( numeric)?( json_key='(.*?)')?\]/
  OPTION_REGEX = /\[option (best|current|selected) ([0-9]+)( cap| low)?( distinctTie)?( imageOnly)?\]/
  PROPERTY_REGEX = /\[property id=("|')([0-9]+)("|')( traditional_value)?\]/
  PREF_REGEX = /\[pref_report (tabulate)\]/
  LINKOUT_REGEX = /\[link_out href="(.*?)" display="(.*?)"\]/
  DCE_REGEX = /\[dce_response question_set="([0-9]+)"\]/
  DECIDE_REGEX = /\[decide (lt|rt|lm|rm|lb|rb|ll4|rl4|ll3|rl3|ll2|rl2|ll1|rl1)\]/
  OTHER_PROPS_REGEX = /\[user_defined_properties\]/
  REB_IMP_PROPS_REGEX = /\[reb_important_props\]/
  UNION = Regexp.union([RESPONSE_REGEX,OPTION_REGEX,PROPERTY_REGEX,PREF_REGEX,LINKOUT_REGEX,DCE_REGEX,DECIDE_REGEX,OTHER_PROPS_REGEX,REB_IMP_PROPS_REGEX])

  module ClassMethods

    def injectable_attributes(attributes)

      define_method "find_injectable_count" do |val|
        #union = Regexp.union([RESPONSE_REGEX,OPTION_REGEX,PREF_REGEX])
        matches = val.to_enum(:scan, UNION).map{Regexp.last_match}.group_by{|matched_group| 
          matched_group[0][/(question|option|property|pref_report|link_out|dce_response|decide|user_defined_properties|reb_important_props)/, 0]
        }
      end

      define_method "find_option_title_from_hash" do |h, distinctTie, imageOnly|
        if !h.empty?
          sorted = h.to_a.sort_by{|ia| ia[1]}.reverse
          tied = (distinctTie and sorted.length > 1 and sorted[0][1] == sorted[1][1])
          #o_id = h.max_by{|k,v| v}[0]
          if tied
            return "be undecided about"
          else
            o = Option.find(sorted[0][0])
            if o
              if imageOnly
                return o.original_image_url
              else
                return o.title
              end
            end
          end
        end
        return ""
      end

      attributes.each do |atr|

        define_method "injected_#{atr}" do |decision_aid_user|
          val = send(atr)
          if val
            matches = find_injectable_count(val)
            rs = Hash.new
            if matches["question"]
              question_ids = matches["question"].map{|match| match[2]}
              rs = DecisionAidUserResponse.where(question_id: question_ids, decision_aid_user_id: decision_aid_user.id)
                  .joins("LEFT OUTER JOIN question_responses ON question_responses.id = decision_aid_user_responses.question_response_id")
                  .joins("LEFT OUTER JOIN questions on questions.id = decision_aid_user_responses.question_id")
                  .select("decision_aid_user_responses.*, 
                           question_responses.numeric_value AS numeric_response_value, 
                           question_responses.question_response_value AS question_response_value,
                           question_responses.is_text_response AS is_text_response", 
                          "questions.question_response_type AS question_response_type, 
                           questions.num_decimals_to_round_to AS num_decimals_to_round_to, 
                           questions.hidden AS is_hidden")
                  .index_by(&:question_id)
            end
            if matches["option"] || matches["pref_report"] || matches["dce_response"] || matches["decide"]
              da = DecisionAid.find decision_aid_user.decision_aid_id
            end

            if matches.any?{|m| m.length > 0}
              val.gsub! UNION do |match|

                type = match[/(question|option|pref_report|link_out|dce_response|decide|user_defined_properties|property|reb_important_props)/, 0]
                case type
                when "question"
                  numeric = match[/numeric/, 0]
                  json_key = match[/json_key='(.*?)'/, 1]
                  id = /[0-9]+/.match(match).to_s
                  if r = rs[id.to_i]
                    case r.question_response_type
                    when Question.question_response_types[:text]
                      r.response_value
                    when Question.question_response_types[:radio], Question.question_response_types[:yes_no]
                      
                      v = if numeric
                        r.numeric_response_value 
                      elsif r.is_text_response  and !r.response_value.blank?
                        r.question_response_value + " (" + r.response_value + ")" 
                      else 
                        r.question_response_value 
                      end

                      if v.is_a?(Float) and v % 1 == 0
                        v.to_i
                      else
                        v
                      end
                    when Question.question_response_types[:ranking], Question.question_response_types[:sum_to_n]
                      "[TODO RANKING AND SUM_TO_N INJECTION]"
                    when Question.question_response_types[:number], Question.question_response_types[:slider]
                      if r.number_response_value
                        if r.is_hidden
                          sprintf("%.#{r.num_decimals_to_round_to}f", r.number_response_value.round(r.num_decimals_to_round_to))
                        else
                          r.number_response_value.round
                        end
                      end
                    when Question.question_response_types[:lookup_table]
                      v = r.lookup_table_value.to_f
                      if v % 1 == 0
                        v.to_i
                      else
                        v
                      end
                    when Question.question_response_types[:json]
                      if r.json_response_value
                        r.json_response_value[json_key]
                      else
                        nil
                      end
                    else
                      nil
                    end
                  else
                    nil
                  end
                when "option"
                  m = match[/(best|current|selected)/, 1]
                  sdorder = match[/([0-9]+)/, 1]
                  cap = match[/( cap| low)/, 1]
                  distinctTie = match[/( distinctTie)/, 1]
                  imageOnly = match[/( imageOnly)/, 1]
                  s = ""
                  if m == "best"
                    scoreHash = nil
                    case da.decision_aid_type
                    when "treatment_rankings"
                      scoreHash = da.option_match_from_treatment_rankings(decision_aid_user, sdorder)
                    when "dce"
                      scoreHash = da.option_match_from_dce(decision_aid_user)
                    when "best_worst"
                      scoreHash = da.option_match_from_best_worst(decision_aid_user, sdorder)
                    when "standard", "standard_enhanced", "decide"
                      scoreHash = da.option_match_from_standard(decision_aid_user, sdorder)
                    else "todo"
                      s = ""
                    end

                    if scoreHash
                      s = find_option_title_from_hash(scoreHash, distinctTie == " distinctTie", imageOnly)
                    end

                  elsif m == "selected"
                    sdc = decision_aid_user.decision_aid_user_sub_decision_choices
                      .joins("LEFT OUTER JOIN sub_decisions on sub_decisions.id = decision_aid_user_sub_decision_choices.sub_decision_id")
                      .where("sub_decisions.sub_decision_order = #{sdorder}").take
                    if sdc
                      o = Option.find(sdc.option_id)
                      if o
                        if imageOnly
                          s = o.original_image_url
                        else
                          s = o.title
                        end
                      end
                    end
                  elsif m == "current"
                    co = da.current_treatment(decision_aid_user, sdorder)
                    if co
                      if imageOnly
                        s = o.original_image_url
                      else
                        s = co.title
                      end
                    end
                  end
                  if cap == " cap"
                    s = s.capitalize
                  elsif cap == " low"
                    s = s.downcase
                  end
                  s
                when "property"
                  id = /[0-9]+/.match(match).to_s
                  trad_val = match[/traditional_value/, 0]
                  user_prop = DecisionAidUserProperty.find_by(decision_aid_user_id: decision_aid_user.id, property_id: id)
                  if user_prop
                    if trad_val
                      user_prop.traditional_value.round
                    else
                      user_prop.weight 
                    end
                  else
                    ""
                  end
                when "reb_important_props"
                  if decision_aid_user.decision_aid_user_properties_count > 0
                    # user took the long path
                    # find all properties weighted >= 4
                    user_props = decision_aid_user.decision_aid_user_properties
                                  .joins("LEFT OUTER JOIN properties ON (decision_aid_user_properties.property_id = properties.id)")
                                  .select("decision_aid_user_properties.traditional_value, properties.backend_identifier AS prop_title")
                                  .where("decision_aid_user_properties.traditional_value >= 4")
                                  .order("decision_aid_user_properties.traditional_value DESC")

                    if user_props.length == 0
                      user_props = decision_aid_user.decision_aid_user_properties
                                  .joins("LEFT OUTER JOIN properties ON (decision_aid_user_properties.property_id = properties.id)")
                                  .select("decision_aid_user_properties.traditional_value, properties.backend_identifier AS prop_title")
                                  .where("decision_aid_user_properties.traditional_value >= 3")
                                  .order("decision_aid_user_properties.traditional_value DESC")
                    end
                    if user_props.length == 0
                      "<strong>None of the outcomes listed were very important to my decision.</strong>"
                    else
                      "<table class='table fixed-table-layout priorities-table space-bottom'>\
                        <tbody>\
                          #{
                            user_props.map{|up|
                              "<tr>\
                                <td style='width: 25%' class='num-circles'>\
                                  <div>\
                                    #{0.upto(up.traditional_value.to_i-1).map{|n| "<i class='fa fa-star'></i>"}.join
                                    }\
                                  </div>\
                                </td>\
                                <td class='priority'>\
                                #{up.prop_title}\
                                </td>\
                              </tr>\
                              "
                            }.join
                          }
                        </tbody>
                      </table>
                      "
                    end
                  else
                    # user took the short path
                    qrs = decision_aid_user.decision_aid_user_responses
                      .joins("LEFT OUTER JOIN questions ON (questions.id = decision_aid_user_responses.question_id)")
                      .joins("LEFT OUTER JOIN question_responses ON (question_responses.id = decision_aid_user_responses.question_response_id)")
                      .where(question_id: [7673, 7674, 7675, 7676, 7677, 7678, 7679])
                      .where("question_responses.numeric_value >= 4")
                      .select("question_responses.numeric_value, questions.question_text")
                      .order("question_responses.numeric_value DESC")

                    if qrs.length == 0
                      qrs = decision_aid_user.decision_aid_user_responses
                      .joins("LEFT OUTER JOIN questions ON (questions.id = decision_aid_user_responses.question_id)")
                      .joins("LEFT OUTER JOIN question_responses ON (question_responses.id = decision_aid_user_responses.question_response_id)")
                      .where(question_id: [7673, 7674, 7675, 7676, 7677, 7678, 7679])
                      .where("question_responses.numeric_value >= 3")
                      .select("question_responses.numeric_value, questions.question_text")
                      .order("question_responses.numeric_value DESC")
                    end

                    if qrs.length == 0
                      "<strong>None of the outcomes listed were very important to my decision.</strong>"
                    else
                      "<table class='table fixed-table-layout priorities-table space-bottom'>\
                        <tbody>\
                          #{
                            qrs.map{|qr|
                              "<tr>\
                                <td style='width: 25%' class='num-circles'>\
                                  <div>\
                                    #{0.upto(qr.numeric_value.to_i-1).map{|n| "<i class='fa fa-star'></i>"}.join
                                    }\
                                  </div>\
                                </td>\
                                <td class='priority'>\
                                #{qr.question_text}\
                                </td>\
                              </tr>\
                              "
                            }.join
                          }
                        </tbody>\
                      </table>\
                      "
                    end
                  end
                when "decide"
                  list_to_fetch = match[/(lt|rt|lm|rm|lb|rb|ll4|rl4|ll3|rl3|ll2|rl2|ll1|rl1)/, 1]
                  props = nil
                  base_query = da.properties
                    .joins("JOIN option_properties op ON (op.property_id = properties.id)")
                    .joins("JOIN decision_aid_user_properties daup ON (daup.property_id = properties.id)")
                    .joins("JOIN options opt ON (opt.id = op.option_id)")

                  case list_to_fetch
                  when "lt"
                    props = base_query
                      .where("daup.decision_aid_user_id = ? AND daup.weight >= 3 AND opt.option_order = 1", decision_aid_user.id)
                  when "rt"
                    props = base_query
                      .where("daup.decision_aid_user_id = ? AND daup.weight >= 3 AND opt.option_order = 2", decision_aid_user.id)
                  when "lm"
                    props = base_query
                      .where("daup.decision_aid_user_id = ? AND daup.weight BETWEEN 1 AND 2 AND opt.option_order = 1", decision_aid_user.id)
                  when "rm"
                    props = base_query
                      .where("daup.decision_aid_user_id = ? AND daup.weight BETWEEN 1 AND 2 AND opt.option_order = 2", decision_aid_user.id)
                  when "lb"
                    props = base_query
                      .where("daup.decision_aid_user_id = ? AND daup.weight = 0 AND opt.option_order = 1", decision_aid_user.id)
                  when "rb"
                    props = base_query
                      .where("daup.decision_aid_user_id = ? AND daup.weight = 0 AND opt.option_order = 2", decision_aid_user.id)
                  when "ll4"
                    props = base_query
                      .where("daup.decision_aid_user_id = ? AND daup.weight = 4 AND opt.option_order = 1", decision_aid_user.id)
                  when "rl4"
                    props = base_query
                      .where("daup.decision_aid_user_id = ? AND daup.weight = 4 AND opt.option_order = 2", decision_aid_user.id)
                  when "ll3"
                    props = base_query
                      .where("daup.decision_aid_user_id = ? AND daup.weight = 3 AND opt.option_order = 1", decision_aid_user.id)
                  when "rl3"
                    props = base_query
                      .where("daup.decision_aid_user_id = ? AND daup.weight = 3 AND opt.option_order = 2", decision_aid_user.id)
                  when "ll2"
                    props = base_query
                      .where("daup.decision_aid_user_id = ? AND daup.weight = 2 AND opt.option_order = 1", decision_aid_user.id)
                  when "rl2"
                    props = base_query
                      .where("daup.decision_aid_user_id = ? AND daup.weight = 2 AND opt.option_order = 2", decision_aid_user.id)
                  when "ll1"
                    props = base_query
                      .where("daup.decision_aid_user_id = ? AND daup.weight = 1 AND opt.option_order = 1", decision_aid_user.id)
                  when "rl1"
                    props = base_query
                      .where("daup.decision_aid_user_id = ? AND daup.weight = 1 AND opt.option_order = 2", decision_aid_user.id)
                  end

                  if props.nil?
                    "NO INJECTION POSSIBLE"
                  elsif props.empty?
                    "<div style='margin-left: 22px;'>N/A</div>"
                  else
                    "<ul>" + props.pluck(:title).map{|p| "<li>#{p}</li>"}.join("") + "</ul>"
                  end

                when "pref_report"
                  user_prefs = DecisionAidUserProperty.where(decision_aid_user_id: decision_aid_user.id)
                    .order("decision_aid_user_properties.weight DESC")
                    .joins("LEFT OUTER JOIN properties as prop on decision_aid_user_properties.property_id = prop.id")
                    .joins("LEFT OUTER JOIN options as opt on decision_aid_user_properties.traditional_option_id = opt.id")
                    .select("decision_aid_user_properties.*, prop.title as property_title, CASE WHEN opt IS NULL THEN \'Unsure\' ELSE opt.title END as option_title")
                    
                  #indexed_user_prefs = user_prefs.index_by(&:property_id)
                  #sorted_properties = da.properties.ordered
                  "<table class='table table-condensed table-bordered' style='margin-bottom: 0;'>
                    #{user_prefs.map{|p| '<tr><td class=\'col-xs-5\'>' + p.property_title + '</td><td class=\'col-xs-2\' style=\'height: 1px; padding: 0;\'><div style=\'height: 100%; width:' + p.weight.to_s + '%; background-color: ' + p.color + ';\'></div></td><td class=\'col-xs-5\'>' + p.option_title + '</td></tr>'}.join('')}
                  </table>"
                when "user_defined_properties"
                  if !decision_aid_user.other_properties.blank? then decision_aid_user.other_properties else "" end
                when "link_out"
                  base_url = match[/href="(.*?)"/, 1]
                  daqps = decision_aid_user.decision_aid_user_query_parameters.includes(:decision_aid_query_parameter)
                  qps = daqps.map{|qp| "#{qp.decision_aid_query_parameter.output_name}=#{qp.param_value}"}.join("&")
                  url = base_url + qps
                  displayText = match[/display="(.*?)"/, 1]

                  "<a class='btn btn-primary' href='#{url}'>#{displayText}</a>"
                when "dce_response"
                  dce_question_set = /[0-9]+/.match(match).to_s
                  dce_response = decision_aid_user.decision_aid_user_dce_question_set_responses
                    .where(question_set: dce_question_set)
                    .joins("LEFT OUTER JOIN dce_question_set_responses dqsr ON (dqsr.id = decision_aid_user_dce_question_set_responses.dce_question_set_response_id)")
                    .select("dqsr.response_value")
                  matches = ["A", "B", "C", "D", "E", "F", "G"]
                  s = ""
                  if dce_response.count > 0
                    dce_response = dce_response.first
                    s = da.dce_option_prefix + " " + matches[dce_response.response_value-1]
                  end
                  s
                else
                  "INVALID MATCH"
                end
              end
            end
            val
          end
        end
      end
    end
  end
end