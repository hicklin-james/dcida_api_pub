class DecisionAidHomeService

  def initialize(decision_aid, decision_aid_user)
    @decision_aid = decision_aid
    @decision_aid_user = decision_aid_user
  end

  def calculate_links
    @link_index = 0
    pages = Hash.new
    generate_intro_link(pages)
    generate_about_link(pages)
    generate_options_link(pages)
    generate_values_and_results_links(pages)
    generate_sub_decision_links(pages)
    generate_quiz_link(pages)
    generate_summary_link(pages)
    pages
  end

  private

  def generate_intro_link(pages)
    add_to_pages(pages, :intro, "Intro", "Intro", true)
  end

  def generate_about_link(pages)
    if @decision_aid.demographic_questions_count > 0
      add_to_pages(pages, :about, "About Me", "About", true)
    end
  end

  def generate_options_link(pages)
    demographic_responses_count = @decision_aid_user
      .decision_aid_user_responses
      .joins(:question)
      .where("questions.question_type = ?", Question.question_types[:demographic])
      .where("questions.hidden = ?", false)
      .references(:question)
      .count
    available = if pages[:about]
      demographic_responses_count == @decision_aid.demographic_questions_count
    else
      true
    end
    page_link_params = {"sub_decision_order" => 1}
    add_to_pages(pages, :options, "Options", "Options", available, page_link_params)
  end

  def generate_values_and_results_links(pages)
    first_results_params = {"sub_decision_order" => 1}
    if @decision_aid.decision_aid_type == "dce"
      add_to_pages(pages, :dce, "My Values", "Dce", pages[:options][:available])
      dce_question_set_count = @decision_aid.dce_question_set_count
      results_available = dce_question_set_count ? @decision_aid_user.decision_aid_user_dce_question_set_responses_count >= dce_question_set_count : false
      add_to_pages(pages, :results, "My Choice", "Results", results_available, first_results_params)
    elsif @decision_aid.decision_aid_type == "best_worst"
      add_to_pages(pages, :best_worst, "My Values", "BestWorst", pages[:options][:available])
      results_available = @decision_aid_user.decision_aid_user_bw_question_set_responses_count >= @decision_aid.bw_question_set_count
      add_to_pages(pages, :results, "My Choice", "Results", results_available, first_results_params)
    elsif @decision_aid.decision_aid_type == "traditional"
      results_available = pages[:options][:available]
      add_to_pages(pages, :results, "My Choice", "Results", results_available, first_results_params)
    else
      add_to_pages(pages, :properties, "My Goals", "Properties", pages[:options][:available])
      results_available = ((@decision_aid.minimum_property_count) > 0 and (@decision_aid_user.decision_aid_user_properties_count >= @decision_aid.minimum_property_count))
      add_to_pages(pages, :results, "My Choice", "Results", results_available, first_results_params)
    end
  end

  def generate_sub_decision_links(pages)
    sdcs = @decision_aid_user
      .decision_aid_user_sub_decision_choices
      .joins(:sub_decision)
      .select("decision_aid_user_sub_decision_choices.*, sub_decisions.sub_decision_order as sub_decision_order")
      .order("sub_decisions.sub_decision_order ASC")
    
    sub_decisions = @decision_aid.sub_decisions
      .index_by(&:sub_decision_order)

    sdcs.each_with_index do |sdc, i|
      nsd = sub_decisions[sdc.sub_decision_order+1]
      if @decision_aid.sub_decisions_count > 1 and 
          nsd and
          nsd.required_option_ids.include?(sdc.option_id)

        opts = "decision_#{i+2}_options".to_sym
        choice = "decision_#{i+2}_my_choice".to_sym

        add_to_pages(pages, opts, "Options", "Options", true, {"sub_decision_order" => i+2})
        add_to_pages(pages, choice, "My Choice", "Results", true, {"sub_decision_order" => i+2})
      end
    end
  end

  def generate_quiz_link(pages)
    if @decision_aid.quiz_questions_count > 0
      add_to_pages(pages, :quiz, "Review", "Quiz", quiz_link_available)
    end
  end

  def generate_summary_link(pages)
    quiz_responses_count = @decision_aid_user.decision_aid_user_responses.joins(:question)
      .where("questions.question_type = ?", Question.question_types[:quiz])
      .references(:question)
      .count
    summary_available = if pages[:quiz] 
      quiz_responses_count == @decision_aid.quiz_questions.count 
    else 
      quiz_link_available
    end
    add_to_pages(pages, :summary, "Summary", "Summary", summary_available)
  end

  def quiz_link_available
    return true if @decision_aid.sub_decisions_count == @decision_aid_user.decision_aid_user_sub_decision_choices_count
    sub_decision_choices = @decision_aid_user.decision_aid_user_sub_decision_choices.index_by(&:sub_decision_id)
    @decision_aid.sub_decisions.each_with_index do |sd, i|
      next_sd = if @decision_aid.sub_decisions_count > i + 1 then @decision_aid.sub_decisions[i+1] else nil end
      dasdc = sub_decision_choices[sd.id]
      return true if next_sd.nil? and dasdc
      return true if next_sd and dasdc and !next_sd.required_option_ids.include?(dasdc.option_id)
    end  
    return false
  end

  def add_to_pages(pages, key, page_title, page_name, available, page_params = nil)
    pages[key] = {page_title: page_title,
                  page_name: page_name,
                  page_index: @link_index,
                  available: available,
                  page_params: page_params}
    @link_index += 1
  end
end
