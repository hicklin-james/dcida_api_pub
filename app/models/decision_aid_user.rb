# == Schema Information
#
# Table name: decision_aid_users
#
#  id                                                 :integer          not null, primary key
#  decision_aid_id                                    :integer          not null
#  selected_option_id                                 :integer
#  created_at                                         :datetime         not null
#  updated_at                                         :datetime         not null
#  decision_aid_user_responses_count                  :integer          default(0), not null
#  decision_aid_user_properties_count                 :integer          default(0), not null
#  decision_aid_user_option_properties_count          :integer          default(0), not null
#  decision_aid_user_dce_question_set_responses_count :integer          default(0), not null
#  decision_aid_user_bw_question_set_responses_count  :integer          default(0), not null
#  decision_aid_user_sub_decision_choices_count       :integer          default(0), not null
#  about_me_complete                                  :boolean          default(FALSE)
#  quiz_complete                                      :boolean          default(FALSE)
#  randomized_block_number                            :integer
#  unique_id_name                                     :integer
#  estimated_end_time                                 :datetime
#  other_properties                                   :text
#  platform                                           :string
#

class DecisionAidUser < ApplicationRecord

  belongs_to :decision_aid
  has_one :decision_aid_user_session, dependent: :destroy
  has_many :decision_aid_user_responses, dependent: :destroy
  has_many :decision_aid_user_properties, dependent: :destroy
  has_many :decision_aid_user_option_properties, dependent: :destroy
  has_many :decision_aid_user_dce_question_set_responses, dependent: :destroy
  has_many :decision_aid_user_bw_question_set_responses, dependent: :destroy
  has_many :decision_aid_user_skip_results, dependent: :destroy
  has_many :decision_aid_user_summary_pages, dependent: :destroy
  belongs_to :selected_option, class_name: "Option", optional: true
  has_many :decision_aid_user_sub_decision_choices, dependent: :destroy
  enum unique_id_name: { pid: 0, psid: 1, p_id: 2, patient_id: 3 }

  has_one :progress_tracker, dependent: :destroy
  has_many :basic_page_submissions, dependent: :destroy

  has_many :decision_aid_user_query_parameters, dependent: :destroy
  accepts_nested_attributes_for :decision_aid_user_query_parameters

  has_many :download_items

  after_create :populate_remote_questions
  after_create :initialize_progress_tracker

  validates :decision_aid_id, :presence => true

  def self.find_or_create_decision_aid_user(decision_aid, dauid, extra_params_hash, user_agent_str)
    user_query = DecisionAidUser.where(decision_aid_id: decision_aid.id)
    qps = decision_aid.decision_aid_query_parameters
    primary_param = qps.find{|qp| qp.is_primary}
    if extra_params_hash.nil?
      extra_params_hash = {}
    end
    primary_query_param = DecisionAidUserQueryParameter.where(decision_aid_query_parameter_id: primary_param.id, param_value: extra_params_hash[primary_param.input_name]).take
    if primary_query_param.nil?
      user_query = user_query.where(id: dauid)
    else
      user_query = [primary_query_param.decision_aid_user]
    end
    if user_query.length > 0
      {user: user_query.first, new_user: false}
    else
      new_qps = []
      qps.each do |qp|
        if extra_params_hash.has_key?(qp.input_name)
          new_qps.push({param_value: extra_params_hash[qp.input_name], decision_aid_query_parameter_id: qp.id})
        end
      end
      
      u = DecisionAidUser.new(decision_aid_id: decision_aid.id, decision_aid_user_query_parameters_attributes: new_qps)
      u.parse_and_set_user_agent(user_agent_str)

      if u.save
        {user: u, new_user: true}
      else
        {user_error: u}
      end
    end
  end

  def trigger_summary_page_emails
    summary_pages = SummaryPage.where(decision_aid_id: self.decision_aid_id, include_admin_summary_email: true)
    if summary_pages.count > 0
      SummaryEmailWorker.perform_async(self.id)
    end
  end

  def parse_and_set_user_agent(ua_string)
    ua = UserAgent.parse(ua_string)
    self.platform = ua.platform
  rescue
    self.platform = nil
  end

  def prepare_summary_html(summary_page)
    require 'open-uri'
    options = self.decision_aid.relevant_options(self, nil, nil)
      .joins(:sub_decision)
      .includes(:media_file)
      .select("sub_decisions.sub_decision_order as sub_decision_order, options.*")

    htmlDiv = "<div class='offscren-content-inner'>"
    htmlDiv += summary_page.summary_panels.ordered.map{|sp|
      "<div class='summary-panel-outer'>" + sp.injected_panel_information_published(self) + "</div>"
    }.join("")
    htmlDiv += "</div>"
    
    html = htmlDiv

    stylesheet_link = "#{ENV['WEBAPP_BASE']}/styles/main_dist.css"
    html = html.prepend("<link rel='stylesheet' href='#{stylesheet_link}'>")
    html = html.prepend('<style>body {font-size: 12pt;} table {font-size: 12pt;} tr {page-break-inside: avoid;}</style>')
    html = html.prepend("<style>#{self.decision_aid.custom_css}</style>")
    
    primary_param = self.decision_aid_user_query_parameters
      .joins(:decision_aid_query_parameter)
      .where("decision_aid_query_parameters.is_primary = ?", true)
      .select("decision_aid_user_query_parameters.*, decision_aid_query_parameters.input_name as input_name").take
    
    if primary_param and primary_param.param_value
      html.prepend('<div class="text-right"><p>' + 
                   primary_param.input_name + 
                   ': ' + 
                   primary_param.param_value + 
                   "</p><p>Completed on: #{Time.now.strftime("%B %-d, %Y at %I:%M %p")}</p></div>")
    else
      html.prepend('<div class="text-right"><p>' +
                   "Completed on: #{Time.now.strftime("%B %-d, %Y at %I:%M %p")}</p></div>")
    end
    
    parsed_html = Nokogiri::HTML(html)
    parsed_html.css("body").first["style"] = "width: 1140px;"

    parsed_html.to_s
  end

  def update_progress_tracker(decision_aid, flag=nil)
    SectionTracker.transaction do
      tracker = self.progress_tracker.section_trackers.find_by(page: SectionTracker.pages[:about])
      if (tracker and decision_aid.demographic_questions_count == 0) or flag == "demo_destroy"
        tracker.destroy()
      elsif (tracker.blank? and decision_aid.demographic_questions_count > 0) or flag == "demo_create"
        st = SectionTracker.create!(progress_tracker_id: self.progress_tracker.id, page: "about")
        intro_section = self.progress_tracker.section_trackers.find_by(page: SectionTracker.pages[:intro])
        st.change_order(intro_section.section_tracker_order + 1)
      end
      tracker = self.progress_tracker.section_trackers.find_by(page: SectionTracker.pages[:quiz])
      if (tracker and decision_aid.quiz_questions_count == 0) or flag == "quiz_destroy"
        tracker.destroy()  
      elsif (tracker.blank? and decision_aid.quiz_questions_count > 0) or flag == :quiz_create
        st = SectionTracker.create!(progress_tracker_id: self.progress_tracker.id, page: "quiz")
        summary_section = self.progress_tracker.section_trackers.find_by(page: SectionTracker.pages[:summary])
        st.change_order(summary_section.section_tracker_order)    
      end
    end
  end

  def find_prev_question_page(current_question_page_id, page_section)
    qp = (if current_question_page_id then QuestionPage.find(current_question_page_id) else nil end)
    if qp
      skip_results = self.decision_aid_user_skip_results
        .where(target_question_page_id: qp.id).order("updated_at DESC")
        .where("qps.section = ?", QuestionPage.sections[page_section])
        .joins("LEFT OUTER JOIN question_pages qps ON (qps.id = decision_aid_user_skip_results.source_question_page_id)")

      if skip_results.count > 0
        QuestionPage.find(skip_results.first.source_question_page_id)
      else
        qps = QuestionPage.where(section: QuestionPage.sections[page_section], decision_aid_id: self.decision_aid_id, question_page_order: qp.question_page_order - 1)
        if qps.length > 0
          qps.first
        else
          nil
        end
      end
    else

      # find the last question
      skip_results = self.decision_aid_user_skip_results
        .where(target_type: [DecisionAidUserSkipResult.target_types["end_of_questions"],DecisionAidUserSkipResult.target_types["other_section"]]).order("updated_at DESC")
        .where("qps.section = ?", QuestionPage.sections[page_section])
        .joins("LEFT OUTER JOIN question_pages qps ON (qps.id = decision_aid_user_skip_results.source_question_page_id)")

      if skip_results.count > 0
        QuestionPage.find(skip_results.first.source_question_page_id)
      else
        QuestionPage
          .where(
            decision_aid_id: self.decision_aid_id, 
            section: QuestionPage.sections[page_section]
          )
          .ordered
          .last
      end
    end
  end

  def time_to_complete
    started = self.created_at
    ended = self.estimated_end_time
    if ended
      seconds = ended - started
      hours = seconds / (60 * 60)
      minutes = (seconds / 60) % 60
      seconds = seconds % 60

      "#{ hours.to_i }h #{ minutes.to_i }m #{ seconds.to_i }s"
    end
  end

  def pid
    p = self.decision_aid_user_query_parameters
      .joins(:decision_aid_query_parameter)
      .where("decision_aid_query_parameters.is_primary = ?", true)
      .select("decision_aid_user_query_parameters.param_value").take

    if p and p.respond_to?(:param_value)
      p.param_value
    else
      nil
    end
  end

  def get_remote_data_targets
    DataExportField.where(exporter_type: "Other", decision_aid_id: self.decision_aid_id)
  end

  def do_async_summary_page_work
    SummaryPageWorker.perform_async(self.id)
  end

  private

  def populate_remote_questions
    da = self.decision_aid
    imported_remote_question_ids = []
    if da.redcap_url and da.redcap_token
      redcap_questions = da.questions.where(remote_data_source: true, remote_data_source_type: Question.remote_data_source_types[:redcap]).includes(:question_responses)
      redcap_importer = RedcapService.new(da)

      redcap_question_ids = redcap_importer.import(redcap_questions, self)
      if redcap_question_ids
        imported_remote_question_ids.concat redcap_question_ids
      end
    end

    if da.mysql_dbname
      mysql_questions = da.questions.where(remote_data_source: true, remote_data_source_type: Question.remote_data_source_types[:my_sql]).includes(:question_responses, :my_sql_question_params) 
      mysql_importer = MySqlImportService.new(da)
      mysql_question_ids = mysql_importer.import(mysql_questions, self)
    
      if mysql_question_ids
        imported_remote_question_ids.concat mysql_question_ids
      end
    end

    # puts "Imported remote question ids: #{imported_remote_question_ids}"
      
    if imported_remote_question_ids.length > 0
      reliant_questions = da.questions
        .where(hidden: true, remote_data_source: false)
        .includes(:question_responses)
        .get_related_hidden_questions(imported_remote_question_ids)
        .to_a.uniq

      while true
        curr_reliant_question_ids = reliant_questions.map(&:id)
        imported_remote_question_ids = imported_remote_question_ids.concat(curr_reliant_question_ids).uniq
        more_questions =  da.questions
          .where(hidden: true, remote_data_source: false)
          .where.not(id: curr_reliant_question_ids)
          .includes(:question_responses)
          .get_related_hidden_questions(imported_remote_question_ids)
          .to_a.uniq
        reliant_questions.concat more_questions
        # puts "\n\n\nReliant questions: #{reliant_questions.map(&:id)}\n\n\n"
        if more_questions.length == 0
          break
        end
      end
      
      Question.batch_create_and_update_hidden_responses(reliant_questions, self)

      rdts = Question.get_remote_data_targets(imported_remote_question_ids).pluck(:id)
      if rdts.length > 0
        DataTargetExportWorker.perform_async(rdts, self.id)
      end
    end
  end

  def initialize_progress_tracker
    ProgressTracker.create(decision_aid_user_id: self.id)
  end
end
