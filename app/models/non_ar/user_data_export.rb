require 'csv'

class UserDataExport

  TMP_PATH = "tmp/download_tmp/user_data_exports"

  EXPORT_ATTRS = {
    created_at: {
      single: true,
      label: "Created at",
      value_func: "created_at"
    },
    id: {
      single: true,
      label: "ID",
      value_func: "id"
    },
    pid: {
      single: true,
      label: "PID",
      value_func: "pid"
    },
    platform: {
      single: true,
      label: "Platform",
      value_func: "platform"
    },
    block_number: {
      single: true,
      label: "Block",
      value_func: "randomized_block_number"
    },
    time_to_complete: {
      single: true,
      label: "Time to complete",
      value_func: "time_to_complete"
    },
    other_values: {
      single: true,
      label: "Other values entered",
      value_func: "other_properties"
    },
    prop_weights: {
      single: false,
      label_func: "get_property_weight_labels",
      value_func: "get_property_weight_values"
    },
    op_weights: {
      single: false,
      label_func: "get_option_property_weight_labels",
      value_func: "get_option_property_weight_values"
    },
    selected_option: {
      single: false,
      label_func: "get_selected_option_labels",
      value_func: "get_selected_option_values"
    },
    match_percentages: {
      single: false,
      label_func: "get_match_percentage_labels",
      value_func: "get_match_percentage_values"
    },
    dce_selections: {
      single: false,
      label_func: "get_dce_selection_labels",
      value_func: "get_dce_selection_values"
    },
    best_worst_selections: {
      single: false,
      label_func: "get_best_worst_selection_labels",
      value_func: "get_best_worst_selection_values"
    }
  }

  def initialize(decision_aid, download_item, user_id, export_params)
    @decision_aid = decision_aid
    @ordered_props = @decision_aid.properties.ordered
    @ordered_sub_decisions = @decision_aid.sub_decisions.ordered
    @ordered_options = @decision_aid.options
      .joins(:sub_decision)
      .order("sub_decisions.sub_decision_order ASC, options.option_order ASC")
    @ordered_option_properties = @decision_aid.option_properties
      .joins(:option => [:sub_decision])
      .joins(:property)
      .order("sub_decisions.sub_decision_order ASC, options.option_order ASC, properties.property_order ASC")
    
    @dce_question_sets = @decision_aid
      .dce_question_set_responses
      .select("dce_question_set_responses.*, dce_question_sets.question_title")
      .joins("LEFT OUTER JOIN dce_question_sets ON (dce_question_sets.dce_question_set_order = dce_question_set_responses.question_set AND dce_question_sets.decision_aid_id = #{@decision_aid.id})")
      .order("dce_question_set_responses.question_set ASC")
      .group_by(&:question_set)

    @best_worst_question_sets = @decision_aid.bw_question_set_responses.order(:question_set).group_by(&:question_set)

    @download_item = download_item
    @time_started = Time.now.strftime("%Y%m%d%H%M%S")
    @user_id = user_id
    @export_params = JSON.parse(export_params)

    @demo_questions = @decision_aid.questions
      .where(id: @export_params["demographicQuestions"])
      .includes(:question_responses, :grid_questions => [:question_responses])
      .order(:question_order)

    @hidden_demo_questions = @decision_aid.questions
      .where(id: @export_params["hiddenDemographicQuestions"])
      .includes(:question_responses, :grid_questions => [:question_responses])
      .order(:question_order)
    
    @quiz_questions = @decision_aid.questions
      .where(id: @export_params["quizQuestions"])
      .includes(:question_responses, :grid_questions => [:question_responses])
      .order(:question_order)

    @hidden_quiz_questions = @decision_aid.questions
      .where(id: @export_params["hiddenQuizQuestions"])
      .includes(:question_responses, :grid_questions => [:question_responses])
      .order(:question_order)

    @questions = @demo_questions + @hidden_demo_questions + @quiz_questions + @hidden_quiz_questions

    rel_folder = "system/download_items/#{@time_started}/#{decision_aid.id}"
    @save_path = Rails.env.test? ? "#{Rails.root}/rspec_tmp/#{rel_folder}" : "#{Rails.root}/public/#{rel_folder}"
    FileUtils::mkdir_p @save_path
    @csv_path = "#{@save_path}/#{decision_aid.slug} User Data Export.csv"
    @rel_path = "#{rel_folder}/#{decision_aid.slug} User Data Export.csv"
  end

  def export
    # setup_directories
    # setup the header row
    headers = build_headers
    #values = get_values
    users = get_decision_aid_users

    file = CSV.generate(headers: true) do |csv|
      csv << headers
      users.each do |u|
        csv << get_user_attrs(u)
      end
    end
    
    File.open(@csv_path, 'wb') { |f| f.write("\uFEFF" + file)}
    finish_download_process

  end

  private

  #TODO#
  def build_headers

    headers = @export_params["selections"].map do |ep|
      eat = EXPORT_ATTRS[ep.to_sym]
      if eat 
        if eat[:single]
          eat[:label]
        else
          self.send eat[:label_func]
        end
      end
    end

    qs = @questions.map do |q|
      if q.question_response_type == "grid"
        q.grid_questions.map do |gq|
          qt = if q.question_text then q.question_text else "" end
          gqqt = if gq.question_text then gq.question_text else "" end
          ActionView::Base.full_sanitizer.sanitize(qt).strip + " | " + ActionView::Base.full_sanitizer.sanitize(gqqt).strip
        end
      elsif q.question_response_type == "sum_to_n" or q.question_response_type == "ranking"
        q.question_responses.map do |qr|
          qt = if q.question_text then q.question_text else "" end
          qrt = if qr.question_response_value then qr.question_response_value else "" end
          ActionView::Base.full_sanitizer.sanitize(qt).strip + " | " + ActionView::Base.full_sanitizer.sanitize(qrt).strip
        end
      elsif q.question_response_type == "number" and q.units_array.length > 1
        qt = q.question_text
        qtt = if qt then ActionView::Base.full_sanitizer.sanitize(qt).strip else " " end
        quu = if qt then ActionView::Base.full_sanitizer.sanitize(qt).strip + " | " + "Unit" else "Unit" end
        [qtt, quu]
      else
        qt = q.question_text
        if qt then ActionView::Base.full_sanitizer.sanitize(qt).strip else " " end
      end
    end

    headers.concat qs
    headers.compact.flatten
  end

  def get_match_percentage_labels
    @decision_aid.sub_decisions.ordered.map{|sd|
      sd.options.ordered.map{|o|
        "Sub Decision #{sd.sub_decision_order} - Option: #{o.title} | PERCENTAGE MATCH"
      }
    }
  end

  def get_selected_option_labels
    @decision_aid.sub_decisions.ordered.map {|sd| "Sub Decision #{sd.sub_decision_order} selected option" }
  end

  def get_property_weight_labels
    @ordered_props.map{|p| p.title + " | WEIGHT"}
  end

  def get_option_property_weight_labels
    @ordered_option_properties
      .select("options.title as option_title, properties.title as property_title")
      .map{|op| "Option Property - OPTION: #{op.option_title}, PROPERTY: #{op.property_title} | WEIGHT"}
  end

  def get_user_attrs(u)
    row = @export_params["selections"].map do |ep|
      eat = EXPORT_ATTRS[ep.to_sym]
      if eat 
        if eat[:single]
          v = u.send eat[:value_func]
          if v then v else " " end
        else
          if eat[:value_func]
            self.send eat[:value_func].to_sym, u
          end
        end
      end
    end
    qvs = get_question_values(u)
    row.concat qvs
    row.compact.flatten
  end

  def get_decision_aid_users
    @decision_aid.decision_aid_users.order(:id)
      .includes(:decision_aid_user_properties)
      .includes(:decision_aid_user_sub_decision_choices)
      .includes(:decision_aid_user_responses => [:option])

  end

  def get_property_weight_values(dau)
    indexed_user_props = dau.decision_aid_user_properties.index_by(&:property_id)
    case @decision_aid.decision_aid_type
    when "standard", "treatment_rankings", "decide"
      @ordered_props.map {|p|
        if indexed_user_props[p.id] then indexed_user_props[p.id].weight.to_s else " " end
      }
    when "dce", "best_worst", "traditional", "best_worst_no_results", "dce_no_results", "best_worst_with_prefs_after_choice"
      @ordered_props.map {|p|
        if indexed_user_props[p.id] then indexed_user_props[p.id].traditional_value.to_s else " " end
      }
    else
      " "
    end
  end

  def get_option_property_weight_values(dau)
    indexed_user_props = dau.decision_aid_user_properties.index_by(&:property_id)
    indexed_user_option_props = dau.decision_aid_user_option_properties.index_by{|op| "#{op.option_id} - #{op.property_id}"}
    @ordered_option_properties.map do |op|
      case @decision_aid.decision_aid_type
      when "treatment_rankings", "best_worst", "best_worst_no_results", "best_worst_with_prefs_after_choice", "decide"
        v = op.generate_ranking_value(dau)
        if v then v.to_s else " " end
      when "traditional"
        up = indexed_user_props[op.property_id]
        if up and up.traditional_option_id == op.option_id then "1" else " " end
      when "standard"
        uop = indexed_user_option_props["#{op.option_id} - #{op.property_id}"]
        if uop and uop.value then uop.value.to_s else " " end
      else
        " "
      end
    end
  end

  def get_selected_option_values(dau)
    indexed_sdcs = dau.decision_aid_user_sub_decision_choices.index_by(&:sub_decision_id)
    indexed_options = @ordered_options.index_by(&:id)
    @ordered_sub_decisions.map do |sd|
      sdc = indexed_sdcs[sd.id]
      if sdc and indexed_options[sdc.option_id] then indexed_options[sdc.option_id].title else " " end
    end
  end

  def get_match_percentage_values(dau)
    vals = Hash.new
    @ordered_sub_decisions.each do |sd|
      case @decision_aid.decision_aid_type
      when "best_worst", "best_worst_with_prefs_after_choice", "best_worst_no_results"
        vals[sd.id] = @decision_aid.option_match_from_best_worst(dau, sd.id)
      when "dce", "dce_no_results"
        vals[sd.id] = @decision_aid.option_match_from_dce(dau)
      when "standard", "standard_enhanced", "decide"
        vals[sd.id] = @decision_aid.option_match_from_standard(dau, sd.sub_decision_order)
      when "treatment_rankings"
        vals[sd.id] = @decision_aid.option_match_from_treatment_rankings(dau, sd.sub_decision_order)
      else
        nil
      end
    end

    @ordered_options.map do |o|
      if vals[o.sub_decision_id] and vals[o.sub_decision_id][o.id] then vals[o.sub_decision_id][o.id].to_s else " " end
    end
  end

  def get_question_values(dau)
    dauqrs = dau.decision_aid_user_responses.index_by(&:question_id)
    @questions.map do |q|
      dauqr = dauqrs[q.id]
      case q.question_response_type
        when "radio", "yes_no"
          if dauqr
            daqur_rv = q.question_responses.index_by(&:id)[dauqr.question_response_id]
            if daqur_rv and daqur_rv.question_response_value 
              if daqur_rv.is_text_response and !dauqr.response_value.blank?
                daqur_rv.question_response_value.to_s + " (" + dauqr.response_value.to_s + ")"
              else
                daqur_rv.question_response_value.to_s 
              end
            else 
              " " 
            end
          else
            " "
          end
        when "number"
          if dauqr and dauqr.number_response_value 
            if q.units_array.length > 1
              [dauqr.number_response_value.to_s, dauqr.selected_unit.to_s]
            else
              dauqr.number_response_value.to_s
            end
          else 
            " " 
          end
        when "slider"
          if dauqr and dauqr.number_response_value then dauqr.number_response_value.to_s else " " end
        when "text"
          if dauqr and dauqr.response_value then dauqr.response_value.to_s else " " end
        when "current_treatment"
          if dauqr and dauqr.option and dauqr.option.title then dauqr.option.title.to_s else " " end
        when "lookup_table"
          if dauqr and dauqr.lookup_table_value then dauqr.lookup_table_value.to_s else " " end
        when "ranking", "sum_to_n"
          q.question_responses.map do |qr|
            if dauqr and dauqr.json_response_value and !dauqr.json_response_value[qr.id.to_s].blank?
              dauqr.json_response_value[qr.id.to_s]
            else
              " "
            end
          end
        when "json"
          if dauqr and dauqr.json_response_value then dauqr.json_response_value.to_s else " " end          
        when "grid"
          gqs = q.grid_questions
          gqs.map do |gq|
            dauqr = dauqrs[gq.id]
            if dauqr
              daqur_rv = gq.question_responses.index_by(&:id)[dauqr.question_response_id]
              if daqur_rv and daqur_rv.question_response_value then daqur_rv.question_response_value else " " end
            else
              " "
            end
          end
        else
          ""
        end
    end
  end

  def get_dce_selection_labels
    result = []
    @dce_question_sets.each do |key, question_sets|
      if question_sets.find {|qs| qs.response_value == -1}
        result.push "#{question_sets[0].question_title} response"
        result.push "#{question_sets[0].question_title} opt-out response"
      else
        result.push "#{question_sets[0].question_title}"
      end

      if @decision_aid.include_dce_confirmation_question
        result.push "#{question_sets[0].question_title} confirmation response"
      end

    end
    result
  end
  
  def get_dce_selection_values(dau)
    result = []
    indexedDceResponses = dau.decision_aid_user_dce_question_set_responses.index_by(&:question_set)
    @dce_question_sets.each do |key, question_sets|
      indexed_question_sets = question_sets.index_by(&:id)
      r = indexedDceResponses[key.to_i]
      if question_sets.find {|qs| qs.response_value == -1}
        a = nil
        if r && r.dce_question_set_response_id == -1
          a = -1.to_s
        else
          a = (r && indexed_question_sets[r.dce_question_set_response_id] ? indexed_question_sets[r.dce_question_set_response_id].response_value : " ")
        end
        result.push a
        if r && r.fallback_question_set_id == -1
          result.push -1.to_s
        else
          b = (r && indexed_question_sets[r.fallback_question_set_id] ? indexed_question_sets[r.fallback_question_set_id].response_value : " ")
          result.push b
        end
      else
        if r and r.dce_question_set_response_id == -1
          result.push -1.to_s
        else
          a = (r && indexed_question_sets[r.dce_question_set_response_id] ? indexed_question_sets[r.dce_question_set_response_id].response_value : " ")
          result.push a
        end
      end

      if @decision_aid.include_dce_confirmation_question
        if r
          if r.option_confirmed.nil?
            result.push " "
          elsif r.option_confirmed
            result.push "Yes"
          else
            result.push "No"
          end
        else
          result.push " "
        end
      end

    end
    result
  end

  def get_best_worst_selection_labels
    result = []
    @best_worst_question_sets.each do |key, question_sets|
      result.push "Question set #{key.to_s}: best selection"
      result.push "Question set #{key.to_s}: worst selection"
    end
    result
  end

  def get_best_worst_selection_values(dau)
    result = []
    indexedBestWorstResponses = dau.decision_aid_user_bw_question_set_responses.index_by(&:question_set)
    indexedProperties = @decision_aid.properties.index_by(&:id)
    indexedPropertyLevels = @decision_aid.property_levels.index_by(&:id)
    @best_worst_question_sets.each do |key, question_sets|
      r = indexedBestWorstResponses[key.to_i]
      if r and indexedPropertyLevels[r.best_property_level_id] and indexedProperties[indexedPropertyLevels[r.best_property_level_id].property_id]
        best_prop = indexedProperties[indexedPropertyLevels[r.best_property_level_id].property_id]
        worst_prop = indexedProperties[indexedPropertyLevels[r.worst_property_level_id].property_id]
        result.push best_prop.title
        result.push worst_prop.title
      else
        result.push ""
        result.push ""
      end
    end
    result
  end

  def finish_download_process
    @download_item.update_attributes(file_location: @rel_path, processed: true)

    private_channel = 'complete_' + @user_id.to_s

    s = DecisionAidSerializer.new(@decision_aid)
    adapter = ActiveModel::Serializer::Adapter.create(s)
    WebsocketRails[:downloadItems].trigger private_channel, {download_item: @download_item, decision_aid: adapter.as_json}
    {success: true, download_item: @download_item}
  end

  def handle_error(exception)
    private_channel = 'error_' + @user_id.to_s

    s = DecisionAidSerializer.new(@decision_aid)
    adapter = ActiveModel::Serializer::Adapter.create(s)

    WebsocketRails[:downloadItems].trigger private_channel, {message: exception.message, decision_aid: adapter.as_json[:decision_aid]}
    {success: false, exception: exception, download_item: @download_item}
  end

  def get_values
    dau_arrays = []
    dau_arrays.push decision_aid_title_columns
    dau_arrays.push patient_id_columns
    if @decision_aid.decision_aid_type == 'standard' or @decision_aid.decision_aid_type == 'treatment_rankings' 
      dau_arrays.push user_properties_columns
    end
    if @decision_aid.decision_aid_type == 'standard'   
      dau_arrays.push user_option_property_columns
    end
    dau_arrays.push user_questions_columns(Question.question_types[:demographic])
    dau_arrays.push user_questions_columns(Question.question_types[:quiz])
    dau_arrays.push selected_option_columns

    final_arrays = []
    dau_arrays.first.each_with_index do |a, i|
      inner_array = dau_arrays.map{|aa| aa[i]}.flatten
      final_arrays.push inner_array
    end
    final_arrays
  end

  def generate_headers
    headers = ["Decision Aid", "Patient ID", "Patient UUID", "Patient PID"]
    
    case @decision_aid.decision_aid_type
    when "standard"
      headers.concat @decision_aid.properties.ordered.pluck(:title).map{|p_title| "Weight - #{p_title}"}
      
      option_props = @decision_aid.option_properties
        .joins(:option, :property)
        .order('options.option_order ASC, properties.property_order ASC')
        .pluck("options.title as option_title, properties.title as property_title, option_properties.short_label as short_label")
      
      headers.concat option_props.map{|op| "#{op[0]} - #{op[1]} - #{op[2]}"}
    when "treatment_rankings"
      headers.concat @decision_aid.properties.ordered.pluck(:title).map{|p_title| "Weight - #{p_title}"}
    when "best_worst", "best_worst_with_prefs_after_choice", "best_worst_no_results"
      best_worst_question_sets = Array.new(@decision_aid.bw_question_set_count*2){|index|
        if index % 2 == 0
          "Best question set #{((index / 2) + 1).to_s} Response"
        else
          "Worst question set #{((index / 2) + 1).to_s} Response"
        end
      }
      headers.concat best_worst_question_sets
      # Include option percentage matches for each option
      #headers.push @decision_aid.options..map{|o| }
    end

    demo_questions = Question.ordered_questions_without_grid(@decision_aid, Question.question_types[:demographic])
    headers.concat demo_questions.pluck(:question_text)
    quiz_questions = Question.ordered_questions_without_grid(@decision_aid, Question.question_types[:quiz])
    headers.concat quiz_questions.pluck(:question_text)

    maxResponses = @decision_aid.sub_decisions.count
    headers.concat 0.upto(maxResponses-1).map{|n| "Decision #{n+1} selected option"}
    headers
  end

  def decision_aid_title_columns
    Array.new(@decision_aid.decision_aid_users.count, [@decision_aid.title])
  end

  def patient_id_columns
    @decision_aid.decision_aid_users
      .order('decision_aid_users.id ASC')
      .pluck(:id, :uuid, :pid)
  end

  def selected_option_columns
    values = []
    @decision_aid.decision_aid_users.each do |dau|
      sdcs = dau.decision_aid_user_sub_decision_choices
        .joins(:sub_decision)
        .joins("LEFT OUTER JOIN options on decision_aid_user_sub_decision_choices.option_id = options.id")
        .select('options.title as option_title')
        .order("sub_decisions.sub_decision_order ASC")
      values.push sdcs.map{|sdc|sdc.option_title}
      p sdcs
    end
    values
      

      #.joins('LEFT OUTER JOIN options ON options.id = decision_aid_users.selected_option_id')
      #.order('decision_aid_users.id ASC')
      #.pluck('options.title')
      #.map{|id| [id]}

  end

  def generate_user_response_row(dau, ids, result)
    dau_values = []
    ids.each do |question_id|
      if result.try(:[], dau.id).try(:[], question_id)
        qr = result[dau.id][question_id]
        case qr.question_response_type
        when Question.question_response_types[:radio]
          dau_values.push qr.question_response_value
        when Question.question_response_types[:number]
          dau_values.push qr.number_response_value
        when Question.question_response_types[:text]
          dau_values.push qr.response_value
        when Question.question_response_types[:yes_no]
          dau_values.push qr.question_response_value
        when Question.question_response_types[:current_treatment]
          dau_values.push qr.current_treatment_option_title
        when Question.question_response_types[:lookup_table]
          dau_values.push qr.lookup_table_value
        end
      else
        dau_values.push nil
      end
    end
    dau_values
  end

  def user_questions_columns(question_type)

    ids = Question.ordered_questions_without_grid(@decision_aid, question_type)
      .pluck(:id)

    #Question.find ids
    us = @decision_aid.decision_aid_users
      .joins("LEFT OUTER JOIN decision_aid_user_responses as responses ON responses.decision_aid_user_id = decision_aid_users.id")
      .joins("LEFT OUTER JOIN questions ON responses.question_id = questions.id")
      .joins("LEFT OUTER JOIN question_responses on question_responses.id = responses.question_response_id")
      .joins("LEFT OUTER JOIN options on responses.option_id = options.id")
      .where('questions.question_type = ?', question_type)
      .where("questions.question_response_type != #{Question.question_response_types[:grid]}")
      .order('decision_aid_users.id ASC')
      .select('responses.question_id AS question_id, 
               responses.number_response_value AS number_response_value, 
               questions.question_response_type AS question_response_type, 
               responses.response_value AS response_value, 
               question_responses.question_response_value AS question_response_value, 
               question_responses.is_text_response AS is_text_response,
               decision_aid_users.id,
               options.title AS current_treatment_option_title, 
               responses.lookup_table_value AS lookup_table_value')
      .group_by(&:id)
    
    result = Hash.new
    us.each do |id, dau_array| 
      result[id] = dau_array.index_by(&:question_id)
    end

    final_result = []
    @decision_aid.decision_aid_users.each do |dau|
      final_result.push generate_user_response_row(dau, ids, result)
    end

    final_result
  end

  def generate_user_property_row(dau, ids, result)
    dau_values = []
    ids.each do |prop_id|
      if result.try(:[], dau.id).try(:[], prop_id)
        pr = result[dau.id][prop_id]
        dau_values.push pr.user_weight
      else
        dau_values.push nil
      end
    end
    dau_values
  end

  def user_properties_columns
    ids = @decision_aid.properties.ordered.pluck(:id)

    user_props = @decision_aid.decision_aid_users
      .joins('LEFT OUTER JOIN decision_aid_user_properties as dauprops ON dauprops.decision_aid_user_id = decision_aid_users.id')
      .joins('LEFT OUTER JOIN properties ON dauprops.property_id = properties.id')
      .order('decision_aid_users.id ASC')
      .select('dauprops.weight as user_weight, properties.id as property_id, decision_aid_users.id')
      .group_by(&:id)

   result = Hash.new
   user_props.each do |id, daup_array|
    result[id] = daup_array.index_by(&:property_id)
   end

   final_result = []
   @decision_aid.decision_aid_users.each do |dau|
    final_result.push generate_user_property_row(dau, ids, result)
   end

   final_result
  end

  def generate_user_option_property_row(dau, ids, result)
    dau_values = []
    ids.each do |id_a|
      if result.try(:[], dau.id).try(:[], "#{id_a[0]}-#{id_a[1]}")
        pr = result[dau.id]["#{id_a[0]}-#{id_a[1]}"]
        dau_values.push pr.op_value
      else
        dau_values.push nil
      end
    end
    dau_values
  end

  def user_option_property_columns
    ids = @decision_aid.option_properties
      .joins(:option, :property)
      .order('options.option_order ASC, properties.property_order ASC')
      .pluck(:property_id, :option_id)

    user_option_properties = @decision_aid.decision_aid_users
      .joins('LEFT OUTER JOIN decision_aid_user_option_properties as dauops ON dauops.decision_aid_user_id = decision_aid_users.id')
      .joins('LEFT OUTER JOIN options ON dauops.option_id = options.id')
      .joins('LEFT OUTER JOIN properties ON dauops.property_id = properties.id')
      .order('decision_aid_users.id ASC')
      .select('dauops.value as op_value, properties.id as property_id, options.id as option_id, decision_aid_users.id')
      .group_by(&:id)

    result = Hash.new
    user_option_properties.each do |id, dauop_array|
      result[id] = dauop_array.index_by{|dauop| "#{dauop.property_id}-#{dauop.option_id}"}
    end

    final_result = []
    @decision_aid.decision_aid_users.each do |dau|
      final_result.push generate_user_option_property_row(dau, ids, result)
     end

    final_result

  end



  def setup_directories
    FileUtils::mkdir_p "#{TMP_PATH}/#{@time_started}"
  end
end