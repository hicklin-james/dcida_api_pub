# == Schema Information
#
# Table name: section_trackers
#
#  id                    :integer          not null, primary key
#  progress_tracker_id   :integer
#  sub_decision_id       :integer
#  page                  :integer
#  section_tracker_order :integer
#  skip_section_target   :string
#

class SkipLogicInfiniteLoopError < StandardError
  def initialize(msg="Infinite loop in skip logic")
    super
  end
end

class SectionTracker < ApplicationRecord

  include Shared::Orderable

  belongs_to :sub_decision
  belongs_to :progress_tracker
  
  enum page: {intro: 0, about: 1, options: 2, properties: 3, best_worst: 4, dce: 5, my_choice: 6, quiz: 7, summary: 8, traditional_properties: 9, properties_post_best_worst: 10, properties_enhanced: 11, properties_decide: 12}

  scope :ordered, ->{ order(section_tracker_order: :asc) }

  acts_as_orderable :section_tracker_order, :order_scope
  attr_writer :update_order_after_destroy

  before_create :init_order

  def self.generate_initial_query(pages, decision_aid, progress_tracker_id)
    #puts decision_aid.id
    values = pages.each_with_index.map {|p, ind| "(#{progress_tracker_id},#{SectionTracker.pages[p]},#{p == 'my_choice' ? decision_aid.sub_decisions.first.id : 'NULL'},#{ind+1})"}.join(",")
    ActiveRecord::Base.connection.execute("INSERT INTO section_trackers (progress_tracker_id, page, sub_decision_id, section_tracker_order) VALUES #{values}")
  end

  def self.pages_for_decision_aid_type(decision_aid_type)
    case decision_aid_type
    when "standard"
      #SectionTracker.transaction do
      ["intro", "about",  "properties", "my_choice", "quiz", "summary"]
    when "treatment_rankings"
      ["intro", "about", "properties", "my_choice", "quiz", "summary"]
    when "dce"
      ["intro", "about", "dce", "my_choice", "quiz", "summary"]
    when "best_worst"
      ["intro", "about", "best_worst", "my_choice", "quiz", "summary"]
    when "traditional"
      ["intro", "about", "my_choice", "quiz", "summary"]
    when "best_worst_no_results"
      ["intro", "about", "best_worst", "quiz", "summary"]
    when "risk_calculator"
      ["intro", "about", "quiz", "summary"]
    when "traditional_no_results"
      ["intro", "about", "traditional_properties", "quiz", "summary"]
    when "dce_no_results"
      ["intro", "about", "dce", "quiz", "summary"]
    when "best_worst_with_prefs_after_choice"
      ["intro", "about", "best_worst", "my_choice", "properties_post_best_worst", "quiz", "summary"]
    when "standard_enhanced"
      ["intro", "about", "properties_enhanced", "my_choice", "quiz", "summary"]
    when "decide"
      ["intro", "about", "properties_decide", "quiz", "summary"]
    end
  end

  def self.init_for_decision_aid(decision_aid, progress_tracker_id)
    pages = SectionTracker.pages_for_decision_aid_type(decision_aid.decision_aid_type)
    SectionTracker.generate_initial_query(pages, decision_aid, progress_tracker_id)
  end

  def constants_for_page(decision_aid)
    c = case self.page
      when "intro"
        {
          key: :intro,
          page_title: decision_aid.intro_page_label,
          page_name: "Intro"
        }
      when "about"
        {
          key: :about,
          page_title: decision_aid.about_me_page_label,
          page_name: "About"
        }
      when "options"
        {
          key: :options,
          page_title: "Options",
          page_name: "Options",
          page_params: {"sub_decision_order" => self.sub_decision.sub_decision_order}
        }
      when "properties"
        {
          key: :properties,
          page_title: decision_aid.properties_page_label,
          page_name: "Properties"
        }
      when "properties_post_best_worst"
        {
          key: :properties_post_best_worst,
          page_title: decision_aid.properties_page_label,
          page_name: "PropertiesPostBestWorst"
        }
      when "traditional_properties"
        {
          key: :traditional_properties,
          page_title: decision_aid.properties_page_label,
          page_name: "TraditionalProperties"
        }
      when "properties_enhanced"
        {
          key: :properties_enhanced,
          page_title: decision_aid.properties_page_label,
          page_name: "PropertiesEnhanced"
        }
      when "properties_decide"
        {
          key: :properties_decide,
          page_title: decision_aid.properties_page_label,
          page_name: "PropertiesDecide"
        }
      when "best_worst"
        {
          key: :best_worst,
          page_title: decision_aid.best_worst_page_label,
          page_name: "BestWorst"
        }
      when "dce"
        {
          key: :dce,
          page_title: decision_aid.properties_page_label,
          page_name: "Dce"
        }
      when "my_choice"
        {
          key: "results_#{if self.sub_decision then sub_decision.sub_decision_order else 1 end}".to_sym,
          page_title: decision_aid.results_page_label + (if self.sub_decision and self.sub_decision.sub_decision_order > 1 then " - Decision #{self.sub_decision.sub_decision_order}" else "" end),
          page_name: "Results",
          page_params: {"sub_decision_order" => if self.sub_decision then self.sub_decision.sub_decision_order else 1 end}
        }
      when "quiz"
        {
          key: :quiz,
          page_title: decision_aid.quiz_page_label,
          page_name: "Quiz"
        }
      when "summary"
        {
          key: :summary,
          page_title: decision_aid.summary_page_label,
          page_name: "Summary"
        }
      end
    c[:kn] = self.page
    c
  end

  # determining whether a section is complete changes depending on the section
  def is_complete(decision_aid, decision_aid_user)
    case self.page
    when "intro"
      # count submitted intro pages
      intro_complete(decision_aid, decision_aid_user)
    when "about"
      # count demographic decision_aid_user_responses + 1 for intro to about me questions
      about_me_complete(decision_aid, decision_aid_user)
    when "options"
      # count submitted options
      options_complete(decision_aid, decision_aid_user)
    when "properties"
      # count properties that have both property_id and weight
      values_complete(decision_aid, decision_aid_user)
    when "properties_post_best_worst"
      values_complete(decision_aid, decision_aid_user)
    when "traditional_properties"
      # count properties that have both property_id and weight
      traditional_values_complete(decision_aid, decision_aid_user)
    when "properties_decide"
      #same as normal properties
      decide_values_complete(decision_aid, decision_aid_user)
    when "properties_enhanced"
      # same as normal properties
      values_complete(decision_aid, decision_aid_user)
    when "best_worst"
      # count decision_aid_user_bw_question_set_responses + 1 for intro to best/worst experiment
      best_worst_complete(decision_aid, decision_aid_user)
    when "dce"
      # count decision_aid_user_dce_questino_set_responses + 1 for intro to DCE
      dce_complete(decision_aid, decision_aid_user)
    when "my_choice"
      # 1 - just a table
      my_choice_complete(decision_aid, decision_aid_user)
    when "quiz"
      # count quiz decision_aid_user_responses + 1 for intro to quiz questions
      quiz_complete(decision_aid, decision_aid_user)
    when "summary"
      # 1 - just a single screen
      summary_complete(decision_aid, decision_aid_user)
    end
  end

  private

  def questions_on_page_complete(questions, user_responses)
    return true if !questions
    return questions.all?{ |q| user_responses[q.id] }
  end

  def question_section_complete(question_type, decision_aid, decision_aid_user)
    questions = decision_aid.questions.where(question_type: Question.question_types[question_type]).ordered
      .where(question_id: nil, hidden: false)
      .includes(:question_responses => [:skip_logic_targets])
      .group_by(&:question_page_id)

    section = if question_type == "demographic" then "about" else "quiz" end

    question_pages = decision_aid
      .question_pages
      .where(section: QuestionPage.sections[section], decision_aid_id: decision_aid.id)
      .includes(:skip_logic_targets => :skip_logic_conditions)
      .ordered

    indexed_question_pages = question_pages.index_by(&:id)

    daurs = decision_aid_user.decision_aid_user_responses.index_by{|daur| daur.question_id}

    visited_pages = Hash.new

    curr_page = question_pages.first

    break_flag = false
    completed = false

    begin
      while curr_page
        next_flag = false

        if visited_pages[curr_page.id]
          raise SkipLogicInfiniteLoopError
        end

        page_questions = questions[curr_page.id]

        if !questions_on_page_complete(page_questions, daurs)
          break_flag = true
          break
        end

        if page_questions
          page_questions.each do |question|
            # return false if we haven't answered everything that we need to answer
            # break if !daurs[question.id]
            responses = question.question_responses.index_by(&:id)
            r = responses[daurs[question.id].question_response_id]
            if r and r.skip_logic_target_count > 0
              r.skip_logic_targets.each do |slt|
                case slt.target_entity
                when "question_page"
                  next_pageid = slt.skip_question_page_id
                  visited_pages[curr_page.id] = true
                  curr_page = indexed_question_pages[next_pageid]
                  next_flag = true
                  break
                when "end_of_questions"
                  completed = true
                  break_flag = true
                  break
                when "other_section"
                  break_flag = true
                  self.update_attribute(:skip_section_target, slt.skip_page_url)
                  break
                when "external_page"
                  break_flag = true
                  break
                end
              end
            end
          end
        end

        next if next_flag
        break if break_flag

        if curr_page.skip_logic_target_count > 0
          curr_page.skip_logic_targets.each do |slt|
            skipConditionMet = slt.evaluate_skip_logic_target(decision_aid_user)
            if skipConditionMet
              case slt.target_entity
              when "question_page"
                next_pageid = slt.skip_question_page_id
                visited_pages[curr_page.id] = true
                curr_page = indexed_question_pages[next_pageid]
                next_flag = true
                break
              when "end_of_questions"
                completed = true
                break_flag = true
                break
              when "other_section"
                break_flag = true
                self.update_attribute(:skip_section_target, slt.skip_page_url)
                break
              when "external_page"
                break_flag = true
                break
              end
            end
          end
        end

        next if next_flag
        break if break_flag

        curr_page = question_pages[curr_page.question_page_order]
      end
    rescue SkipLogicInfiniteLoopError => e
      Rails.logger.error "INFINITE LOOP IN SKIP LOGIC"
      return false
    end

    if !break_flag
      completed = true
    end
  
    return completed
  end

  def intro_complete(decision_aid, decision_aid_user)
    intro_pages_completed = decision_aid_user.basic_page_submissions
      .where.not(intro_page_id: nil)
      .count
    intro_pages_completed == decision_aid.intro_pages_count
  end

  def about_me_complete(decision_aid, decision_aid_user)
    if decision_aid_user.about_me_complete
      return true
    else
      b = question_section_complete("demographic", decision_aid, decision_aid_user)
      #decision_aid_user.update_attribute(:about_me_complete, b)
      b
    end
  end

  def options_complete(decision_aid, decision_aid_user)
    options_pages_complete = decision_aid_user.basic_page_submissions
      .where.not(option_id: nil)
      .where(sub_decision_id: self.sub_decision_id)
      .count

    options_pages_complete == decision_aid.relevant_options(decision_aid_user, nil, self.sub_decision_id).length
  end

  def decide_values_complete(decision_aid, decision_aid_user)
    decision_aid_user.decision_aid_user_properties_count >= decision_aid.properties_count
  end

  def values_complete(decision_aid, decision_aid_user)
    prop_count_complete = decision_aid_user.decision_aid_user_properties_count >= decision_aid.minimum_property_count
    props_all_weighed = decision_aid_user.decision_aid_user_properties.where.not(weight: nil).count == decision_aid_user.decision_aid_user_properties_count 

    prop_count_complete and props_all_weighed
  end

  def traditional_values_complete(decision_aid, decision_aid_user)
    count = decision_aid_user.decision_aid_user_properties_count
    values_all_set = decision_aid_user.decision_aid_user_properties.all?{ |up| !up.traditional_option_id.nil? }
    count >= decision_aid.minimum_property_count && count <= decision_aid.maximum_property_count && values_all_set
  end

  def best_worst_complete(decision_aid, decision_aid_user)
    bw_question_set_count = decision_aid.bw_question_set_count
    bw_question_set_count ? decision_aid_user.decision_aid_user_bw_question_set_responses_count >= decision_aid.bw_question_set_count : false
  end

  def dce_complete(decision_aid, decision_aid_user)
    dce_question_set_count = decision_aid.dce_question_set_count
    dce_question_set_count ? decision_aid_user.decision_aid_user_dce_question_set_responses_count >= dce_question_set_count : false
  end

  def my_choice_complete(decision_aid, decision_aid_user)
    decision_aid_user.decision_aid_user_sub_decision_choices.exists?(sub_decision_id: self.sub_decision_id)
  end

  def quiz_complete(decision_aid, decision_aid_user)
    if decision_aid_user.quiz_complete
      return true
    else
      b = question_section_complete("quiz", decision_aid, decision_aid_user)
      #decision_aid_user.update_attribute(:quiz_complete, b)
      b
    end
  end

  def summary_complete(decision_aid, decision_aid_user)
    true
  end

  private

  def init_order
    initialize_order(SectionTracker.where(progress_tracker_id: progress_tracker_id).count)
  end

  def update_order_after_destroy
    true
  end

  def order_scope
    SectionTracker.where(progress_tracker_id: progress_tracker_id).order(section_tracker_order: :asc)
  end
end
