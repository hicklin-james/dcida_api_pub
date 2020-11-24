task :export_user_data, [] => :environment do |t, args|
  property_titles = da.properties.ordered.map{|prop| prop.title + " Weight"}.join("|")
  option_match_percentage_labels = da.sub_decisions.map{|sd| sd.options.ordered.map{|o| o.title + " Percentage Match"}}.flatten
  sub_decision_choice_titles = da.sub_decisions.ordered.each_with_index.map{|sd, ind| "Decision #{ind + 1}"}.join("|")
  
  temp_demo_questions = da.demographic_questions.ordered.where(question_id: nil)
  demographic_questions = []
  temp_demo_questions.each do |q|
    if q.question_response_type == "grid"
      q.grid_questions.ordered.each do |gq|
        demographic_questions.push gq
      end
    else
      demographic_questions.push q
    end
  end

  temp_quiz_questions = da.quiz_questions.ordered.where(question_id: nil)
  quiz_questions = []
  temp_quiz_questions.each do |q|
    if q.question_response_type == "grid"
      q.grid_questions.ordered.each do |gq|
        quiz_questions.push gq
      end
    else
      quiz_questions.push q
    end
  end

  #puts "Patient ID,Patient PID,Patient Created At,#{demographic_questions.map(&:question_text).join('|')}#{property_titles},#{option_match_percentage_labels.join("|")},#{sub_decision_choice_titles}" 
  str = ""
  patients.each do |p|
    patient_id = p.id
    patient_pid = if p.pid then p.pid else " " end
    patient_started = p.created_at
    
    dqrs = []
    daurs = p.decision_aid_user_responses.index_by(&:question_id)
    demographic_questions.each do |q|
      if daurs[q.id]
        case q.question_response_type
        when "radio"
          if daurs[q.id].question_response.question_response_value
            dqrs.push daurs[q.id].question_response.question_response_value
          else
            dqrs.push " "
          end
        when "yes_no"
          if daurs[q.id].question_response.question_response_value
            dqrs.push daurs[q.id].question_response.question_response_value
          else
            dqrs.push " "
          end
        when "number"
          if daurs[q.id].number_response_value.to_s
            dqrs.push daurs[q.id].number_response_value.to_s
          else
            dqrs.push " "
          end
        when "text"
          if daurs[q.id].response_value
            dqrs.push daurs[q.id].response_value
          else
            dqrs.push " "
          end
        when "lookup_table"
          if daurs[q.id].lookup_table_value
            dqrs.push daurs[q.id].lookup_table_value.to_s
          else
            dqrs.push " "
          end
        when "current_treatment"
          if daurs[q.id].option
            dqrs.push daurs[q.id].option.title
          else
            dqrs.push " "
          end
        else
          dqrs.push " "
        end
      else
        dqrs.push " "
      end
    end

    prop_weights = []
    patient_props = p.decision_aid_user_properties.index_by(&:property_id)
    da.properties.ordered.each do |prop|
      if patient_props[prop.id]
        prop_weights.push patient_props[prop.id].traditional_value.to_s
      else
        prop_weights.push " "
      end
    end

    option_match_labels = []
    da.sub_decisions.ordered.each do |sd|
      sdcs = p.decision_aid_user_sub_decision_choices.index_by(&:sub_decision_id)
      sd.options.each do |o|
        if sdcs[sd.id]
          begin
            match = da.option_match_from_treatment_rankings(p, sd.sub_decision_order)
            option_match_labels.push match[o.id].to_s
          rescue
            option_match_labels.push " "
          end
        else
          option_match_labels.push " "
        end
      end
    end
    
    sub_decision_choice_labels = []
    sdcs = p.decision_aid_user_sub_decision_choices.index_by(&:sub_decision_id)
    da.sub_decisions.ordered.each do |sd|
      if sdcs[sd.id]
        if Option.exists?(sdcs[sd.id].option_id)
          o = Option.find(sdcs[sd.id].option_id)
          sub_decision_choice_labels.push o.title
        else
          sub_decision_choice_labels.push " "
        end
      else
        sub_decision_choice_labels.push " "
      end
    end

    qqrs = []
    #daurs = p.decision_aid_user_responses.index_by(&:question_id)
    quiz_questions.each do |q|
      if daurs[q.id]
        case q.question_response_type
        when "radio"
          if daurs[q.id].question_response.question_response_value
            qqrs.push daurs[q.id].question_response.question_response_value
          else
            qqrs.push " "
          end
        when "yes_no"
          if daurs[q.id].question_response.question_response_value
            qqrs.push daurs[q.id].question_response.question_response_value
          else
            qqrs.push " "
          end
        when "number"
          if daurs[q.id].number_response_value.to_s
            qqrs.push daurs[q.id].number_response_value.to_s
          else
            qqrs.push " "
          end
        when "text"
          if daurs[q.id].response_value
            qqrs.push daurs[q.id].response_value
          else
            qqrs.push " "
          end
        when "current_treatment"
          if daurs[q.id].option
            qqrs.push daurs[q.id].option.title
          else
            qqrs.push " "
          end
        else
          qqrs.push " "
        end
      else
        qqrs.push " "
      end
    end

    str += "#{patient_id}|#{patient_pid}|#{patient_started.to_s}|#{dqrs.join("|")}|#{prop_weights.join("|")}|#{option_match_labels.join("|")}|#{sub_decision_choice_labels.join("|")}|#{qqrs.join("|")}\n"
  end
  puts "Patient ID|Patient PID|Patient Created At|#{demographic_questions.map(&:question_text).join('|')}|#{property_titles}|#{option_match_percentage_labels.join("|")}|#{sub_decision_choice_titles}|#{quiz_questions.map(&:question_text).join('|')}" 
  puts str
end

