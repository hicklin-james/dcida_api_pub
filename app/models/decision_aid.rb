# == Schema Information
#
# Table name: decision_aids
#
#  id                                        :integer          not null, primary key
#  slug                                      :string           not null
#  title                                     :string           not null
#  description                               :text
#  created_by_user_id                        :integer
#  updated_by_user_id                        :integer
#  created_at                                :datetime         not null
#  updated_at                                :datetime         not null
#  options_count                             :integer          default(0), not null
#  properties_count                          :integer          default(0), not null
#  option_properties_count                   :integer          default(0), not null
#  demographic_questions_count               :integer          default(0), not null
#  quiz_questions_count                      :integer          default(0), not null
#  question_responses_count                  :integer          default(0), not null
#  about_information                         :text
#  options_information                       :text
#  properties_information                    :text
#  property_weight_information               :text
#  results_information                       :text
#  quiz_information                          :text
#  minimum_property_count                    :integer          default(0)
#  description_published                     :text
#  about_information_published               :text
#  options_information_published             :text
#  properties_information_published          :text
#  property_weight_information_published     :text
#  results_information_published             :text
#  quiz_information_published                :text
#  icon_id                                   :integer
#  footer_logos                              :integer          default([]), is an Array
#  ratings_enabled                           :boolean
#  percentages_enabled                       :boolean
#  best_match_enabled                        :boolean
#  chart_type                                :integer          default(0)
#  decision_aid_type                         :integer          not null
#  dce_information                           :text
#  dce_information_published                 :text
#  dce_specific_information                  :text
#  dce_specific_information_published        :text
#  dce_design_file_file_name                 :string
#  dce_design_file_content_type              :string
#  dce_design_file_file_size                 :integer
#  dce_design_file_updated_at                :datetime
#  dce_results_file_file_name                :string
#  dce_results_file_content_type             :string
#  dce_results_file_file_size                :integer
#  dce_results_file_updated_at               :datetime
#  dce_question_set_responses_count          :integer          default(0), not null
#  dce_design_success                        :boolean          default(FALSE)
#  dce_results_success                       :boolean          default(FALSE)
#  bw_design_success                         :boolean          default(FALSE)
#  bw_design_file_file_name                  :string
#  bw_design_file_content_type               :string
#  bw_design_file_file_size                  :integer
#  bw_design_file_updated_at                 :datetime
#  bw_question_set_responses_count           :integer          default(0), not null
#  best_worst_information                    :text
#  best_worst_information_published          :text
#  best_worst_specific_information           :text
#  best_worst_specific_information_published :text
#  other_options_information                 :text
#  other_options_information_published       :text
#  sub_decisions_count                       :integer          default(0), not null
#  has_intro_popup                           :boolean          default(FALSE)
#  intro_popup_information                   :text
#  intro_popup_information_published         :text
#  summary_panels_count                      :integer          default(0), not null
#  summary_link_to_url                       :string
#  redcap_token                              :string
#  redcap_url                                :string
#  password_protected                        :boolean          default(FALSE)
#  access_password                           :string
#  more_information_button_text              :string
#  final_summary_text                        :text
#  final_summary_text_published              :text
#  intro_pages_count                         :integer          default(0), not null
#  summary_email_addresses                   :string           default([]), is an Array
#  theme                                     :integer          default(0), not null
#  best_wording                              :string           default("Best")
#  worst_wording                             :string           default("Worst")
#  include_admin_summary_email               :boolean          default(FALSE)
#  include_user_summary_email                :boolean          default(FALSE)
#  user_summary_email_text                   :text             default("If you would like these results emailed to you, enter your email address here:")
#  mysql_dbname                              :string
#  mysql_user                                :string
#  mysql_password                            :string
#  contact_phone_number                      :string
#  contact_email                             :string
#  include_download_pdf_button               :boolean          default(FALSE)
#  maximum_property_count                    :integer          default(0)
#  intro_page_label                          :string           default("Introduction")
#  about_me_page_label                       :string           default("About Me")
#  properties_page_label                     :string           default("My Values")
#  results_page_label                        :string           default("My Choice")
#  quiz_page_label                           :string           default("Review")
#  summary_page_label                        :string           default("Summary")
#  opt_out_information                       :text
#  opt_out_information_published             :text
#  properties_auto_submit                    :boolean          default(TRUE)
#  opt_out_label                             :string           default("Opt Out")
#  dce_option_prefix                         :string           default("Option")
#  current_block_number                      :integer          default(1), not null
#  best_worst_page_label                     :string           default("My Values")
#  hide_menu_bar                             :boolean          default(FALSE)
#  open_summary_link_in_new_tab              :boolean          default(TRUE)
#  color_rows_based_on_attribute_levels      :boolean          default(FALSE)
#  compare_opt_out_to_last_selected          :boolean          default(TRUE)
#  use_latent_class_analysis                 :boolean          default(FALSE)
#  language_code                             :integer          default(0)
#  full_width                                :boolean          default(FALSE)
#  custom_css                                :text
#  static_pages_count                        :integer          default(0), not null
#  nav_links_count                           :integer          default(0), not null
#  include_dce_confirmation_question         :boolean          default(FALSE)
#  dce_confirmation_question                 :text
#  dce_confirmation_question_published       :text
#  dce_type                                  :integer          default(1)
#  begin_button_text                         :string           default("Begin"), not null
#  custom_css_file_file_name                 :string
#  custom_css_file_content_type              :string
#  custom_css_file_file_size                 :integer
#  custom_css_file_updated_at                :datetime
#  dce_selection_label                       :string           default("Which do you prefer?")
#  dce_min_level_color                       :string
#  dce_max_level_color                       :string
#  summary_pages_count                       :integer          default(0), not null
#  unique_redcap_record_identifier           :string
#  data_export_fields_count                  :integer          default(0), not null
#

# require 'w3c_validators'
# include W3CValidators

class DecisionAid < ApplicationRecord
  include Shared::UserStamps
  include Shared::HasAttachedItems
  include Shared::Injectable
  include Shared::CrossCloneable
  include Shared::Permissions
  
  validates :slug, :title, :decision_aid_type, :intro_page_label, :about_me_page_label, :language_code,
    :properties_page_label, :results_page_label, :quiz_page_label, :summary_page_label, presence: true

  validates :slug, uniqueness: true

  enum chart_type: { pie: 0, bar: 1 }
  enum decision_aid_type: { standard: 0, dce: 1, treatment_rankings: 2, best_worst: 3, traditional: 4,
  best_worst_no_results: 5, risk_calculator: 6, traditional_no_results: 7, dce_no_results: 8, 
  best_worst_with_prefs_after_choice: 9, standard_enhanced: 10, decide: 11 }
  enum theme: { default: 0, chevron_navigation: 1, flat: 2 }

  enum dce_type: { normal: 1, conditional: 2, opt_out: 3 }

  enum language_code: { en: 0, fr: 1 }

  has_many :intro_pages, dependent: :destroy
  has_many :options, dependent: :destroy
  has_many :properties, dependent: :destroy
  has_many :property_levels, dependent: :destroy
  has_many :option_properties, dependent: :destroy
  has_many :question_pages, dependent: :destroy
  has_many :demographic_question_pages, -> { where(section: 1) }, class_name: "QuestionPage"
  has_many :quiz_question_pages, -> { where(section: 2) }, class_name: "QuestionPage"
  has_many :questions, dependent: :destroy, inverse_of: :decision_aid
  has_many :demographic_questions, -> { where(question_type: 0) }, class_name: "Question"
  has_many :quiz_questions, -> { where(question_type: 1) }, class_name: "Question"
  has_many :question_responses, dependent: :destroy
  has_many :dce_question_set_responses, dependent: :destroy
  has_many :dce_results_matches, dependent: :destroy
  has_many :bw_question_set_responses, dependent: :destroy
  has_many :summary_panels, dependent: :destroy
  has_many :latent_classes, dependent: :destroy
  has_many :dce_question_sets, dependent: :destroy
  has_many :user_permissions, dependent: :destroy
  has_many :nav_links, dependent: :destroy
  has_many :static_pages, dependent: :destroy
  has_many :data_export_fields, dependent: :destroy

  has_many :accordions, dependent: :destroy
  has_many :graphics, dependent: :destroy

  has_many :sub_decisions, -> { ordered }, dependent: :destroy

  has_many :intro_pages, dependent: :destroy

  has_many :skip_logic_targets, dependent: :destroy
  has_many :skip_logic_conditions, dependent: :destroy

  has_many :decision_aid_query_parameters, dependent: :destroy
  accepts_nested_attributes_for :decision_aid_query_parameters, allow_destroy: true

  has_many :download_items

  has_many :summary_pages, dependent: :destroy

  has_attached_file :custom_css_file

  has_attached_file :dce_design_file
  do_not_validate_attachment_file_type :dce_design_file
  #validates_attachment_content_type :dce_design_file, 
  #  content_type: ["text/csv", "text/plain", "application/csv","application/excel","application/vnd.ms-excel","application/vnd.msexcel","text/anytext","text/comma-separated-values"],
  #  message: "not recognized as a CSV file"

  has_attached_file :dce_results_file
  do_not_validate_attachment_file_type :dce_results_file
  #validates_attachment_content_type :dce_results_file, 
  #  content_type: ["text/csv", "text/plain", "application/csv","application/excel","application/vnd.ms-excel","application/vnd.msexcel","text/anytext","text/comma-separated-values"],
  #  message: "not recognized as a CSV file"

  has_attached_file :bw_design_file
  do_not_validate_attachment_file_type :bw_design_file
  #validates_attachment_content_type :dce_results_file, 
  #  content_type: ["text/csv", "text/plain", "application/csv","application/excel","application/vnd.ms-excel","application/vnd.msexcel","text/anytext","text/comma-separated-values"]

  has_many :decision_aid_users, dependent: :destroy

  validate :query_params_length
  validate :validate_custom_css
  validate :validate_dce_colors

  after_create :create_first_sub_decision
  before_validation :create_primary_query_param

  belongs_to :icon, optional: true
  has_many :icons

  default_scope { order(created_at: :asc) }

  HAS_ATTACHED_ITEMS_ATTRIBUTES = [:description, :about_information, :intro_popup_information, :options_information, 
    :properties_information, :property_weight_information, :results_information, :quiz_information,
    :dce_information, :dce_specific_information, :best_worst_information, :best_worst_specific_information,
    :other_options_information, :final_summary_text, :opt_out_information, :dce_confirmation_question].freeze

  attributes_with_attached_items DecisionAid::HAS_ATTACHED_ITEMS_ATTRIBUTES

  INJECTABLE_ATTRIBUTES = [:description_published, :about_information_published, :intro_popup_information_published, 
    :options_information_published, :other_options_information_published, :properties_information_published,
    :property_weight_information_published, :results_information_published, :quiz_information_published, :dce_information_published,
    :dce_specific_information_published, :best_worst_information_published, :best_worst_specific_information_published,
    :final_summary_text_published, :opt_out_information_published, :dce_confirmation_question_published]
    .freeze

  injectable_attributes DecisionAid::INJECTABLE_ATTRIBUTES

  def current_treatment(decision_aid_user, sub_decision_order)
    sub_decision = self.sub_decisions.where(sub_decision_order: sub_decision_order).take
    ctq = self.questions.where(question_response_type: Question.question_response_types[:current_treatment], sub_decision_id: sub_decision.id).take
    if ctq
      ct = decision_aid_user.decision_aid_user_responses.where(question_id: ctq.id).take
      if ct
        if ct.option_id > 0
          return ct.option
        else
          return Option.new(title: "No Treatment/Not Sure")
        end
      end
    end
    return nil
  end

  def option_match_from_standard(decision_aid_user, sub_decision_order)
    sub_decision = self.sub_decisions.where(sub_decision_order: sub_decision_order).take
    return {} if !sub_decision

    os = self.relevant_options(decision_aid_user, nil, sub_decision.id)
    ops = self.option_properties.for_standard_option_match(os.map(&:id), decision_aid_user.id)

    grouped_ops = ops.select{|op| op.property_weight }.group_by {|op| op.option_id}
    indexed_dauops = decision_aid_user.decision_aid_user_option_properties.index_by(&:option_property_id)
    result_hash = Hash.new

    total_score = 0
    
    grouped_ops.each do |key, op_group|
      score = op_group.inject(0) {|acc, op|
        rv = nil
        if op.is_user_weighable
          rv = if indexed_dauops[op.id] and indexed_dauops[op.id].value then indexed_dauops[op.id].value else 0 end
        else
          rv = op.generate_ranking_value(decision_aid_user)
        end
        rv ||= 0
        acc += rv * op.property_weight
      }
      total_score += score.abs
      result_hash[key] = score.abs
    end

    result_hash.each {|k,v| result_hash[k] = if total_score > 0 then (v.abs/total_score)*100 else " " end}
  end

  def option_match_from_treatment_rankings(decision_aid_user, sub_decision_order)
    sub_decision = self.sub_decisions.where(sub_decision_order: sub_decision_order).take
    return {} if !sub_decision

    os = self.relevant_options(decision_aid_user, nil, sub_decision.id)
    ops = self.option_properties.for_standard_option_match(os.map(&:id), decision_aid_user.id)

    grouped_ops = ops.select{|op| op.property_weight }.group_by {|op| op.option_id}
    result_hash = Hash.new

    total_score = 0

    grouped_ops.each do |key, op_group|
      score = op_group.inject(0) {|acc, op|
        ov = op.generate_ranking_value(decision_aid_user)
        acc += ((if ov then ov else 0 end) * op.property_weight)
      }
      total_score += score
      result_hash[key] = score
    end

    result_hash.each {|k,v| result_hash[k] = if total_score > 0 then (v/total_score)*100 else " " end}
  end

  def option_match_from_dce(decision_aid_user)
    # pluck question_set_responses using decision_aid_user_dce_question_set_responses
    set_response_array = DecisionAidUserDceQuestionSetResponse
      .where(:decision_aid_user_id => decision_aid_user.id)
      .includes(:dce_question_set_response)
      .pluck(:"dce_question_set_responses.response_value")
    
    # find matching dce_result_match
    result_match = self.dce_results_matches.where("dce_results_matches.response_combination::integer[] = Array[?]::integer[]", set_response_array)
    # get responses ids as strings
    response_array_strings = decision_aid_user.decision_aid_user_responses.pluck(:question_response_id).map(&:to_s)
    if result_match.length > 0
      # find first match in the option_match_hash array that contains the user response ids
      k = result_match.first.option_match_hash.keys.find {|response_ids| YAML.load(response_ids).all? {|a| a.any? {|ele| response_array_strings.include?(ele) }}}
      result_match.first.option_match_hash[k]
    else
      nil
    end
  end

  def option_match_from_best_worst(decision_aid_user,sub_decision_id=nil)
    bw_hash = build_best_worst_hash(decision_aid_user)
    shifted_hash = shift_and_normalize_bw_hash(bw_hash, decision_aid_user)
    if self.use_latent_class_analysis
      sum_of_shifted_hash = shifted_hash.inject(0){|sum, (k,v)| sum + v}
      relative_weights = Hash[shifted_hash.map{|k,v| [k, (v.to_f/sum_of_shifted_hash.to_f) * 100.0]} ]
      latent_classes = self.latent_classes.includes(:latent_class_options, :latent_class_properties)
      latent_classes_hash = latent_classes.index_by(&:id)
      latent_class_weight_sums = []
      latent_classes.each do |lc|
        local_sum = 0
        lc.latent_class_properties.each do |lcp|
          w = lcp.weight.to_f - relative_weights[lcp.property_id]
          wsqr = w ** 2
          local_sum += wsqr
        end
        latent_class_weight_sums << {lcid: lc.id, sum: local_sum}
      end
      latent_class_weight_sums = latent_class_weight_sums.sort_by{|h| h[:sum]}
      matched_class = latent_classes_hash[latent_class_weight_sums.first[:lcid]]
      final_hash = Hash.new
      matched_class.latent_class_options.each do |lco|
        final_hash[lco.option_id] = lco.weight.to_f/100.0
      end
      final_hash
    else
      ops = option_properties.index_by{|op| "#{op.option_id}-#{op.property_id}"}
      os = self.relevant_options(decision_aid_user, nil, sub_decision_id)
      final_hash = Hash.new
      os.each do |o|
        # puts "\n"
        # puts "Option: #{o.id}"
        final_hash[o.id] = 0.0
        properties.each do |p|
          # puts "Property: #{p.id}"
          op = ops["#{o.id}-#{p.id}"]
          if op
            op_val = op.generate_ranking_value(decision_aid_user)
            if op_val and shifted_hash[p.id]
              final_hash[o.id] += (op_val * shifted_hash[p.id])
            end
          end
        end
      end
      total_sum = final_hash.values.sum
      f = final_hash.each {|k,v| final_hash[k] = ( total_sum == 0 ? 1.0 / final_hash.length : v.to_f / total_sum ) }
      f
    end
  end

  def relevant_options(decision_aid_user, user_response_ids = nil, sub_decision_id = nil)
    ignore_responses = false
    if self.demographic_questions_count > 0
      if user_response_ids.nil?
        # 1. join with question
        # 2. eliminate text responses (no question_response_id)
        # 3. filter so we only use demographic questions
        # 4. pluck the response ids
        user_response_ids = decision_aid_user.decision_aid_user_responses
                              .joins(:question)
                              .where.not(question_response_id: nil)
                              .where("questions.question_type = ?", Question.question_types[:demographic])
                              .pluck(:question_response_id)
      else
        ignore_responses = true
      end

      # 1. joins if option has parent option
      # 2. array operator in postgres checks whether user_response_ids exists in the question_response_array
      # 3. create temp column temp_order using either parent order or option order
      # 4. order by temp_order
      current_treatment_question = self.demographic_questions.where(sub_decision_id: sub_decision_id, question_response_type: Question.question_response_types[:current_treatment]).take
      ct = current_treatment_question ? decision_aid_user.decision_aid_user_responses.where(question_id: current_treatment_question.id).take : nil
      current_treatment_response_id = ((current_treatment_question and ct) ? ct.option_id : -1)

      if user_response_ids.length > 0
        options = self.options
          .joins("LEFT OUTER JOIN options as o on o.id = options.option_id")
          .where("options.question_response_array::integer[] @> ARRAY[?]::integer[] AND options.has_sub_options = ?", user_response_ids, false)
        if sub_decision_id
          options = options
            .where("options.sub_decision_id = ?", sub_decision_id)
        end

        options.select("options.*, CASE WHEN options.option_id is NULL 
          THEN options.option_order 
          ELSE o.option_order END as temp_order,
          CASE WHEN #{current_treatment_response_id} = CASE WHEN options.option_id is NULL THEN options.id ELSE options.option_id END
          THEN 1
          ELSE 0 END as ct_order")
          .order("ct_order DESC, temp_order ASC")
      else
        self.options
          .select("options.*, 
            CASE WHEN #{current_treatment_response_id} = CASE WHEN options.option_id is NULL THEN options.id ELSE options.option_id END
            THEN 1
            ELSE 0 END as ct_order")
            .order("ct_order DESC")
      end
    else
      self.options
    end
  end

  def change_ownership(user_id)
    if User.exists?(id: user_id)
      ActiveRecord::Base.transaction do 
        self.update_attribute(:created_by_user_id, user_id)
        self.options.update_all(:created_by_user_id => user_id)
        self.properties.update_all(:created_by_user_id => user_id)
        self.property_levels.update_all(:created_by_user_id => user_id)
        self.option_properties.update_all(:created_by_user_id => user_id)
        self.questions.update_all(:created_by_user_id => user_id)
        self.question_responses.update_all(:created_by_user_id => user_id)
        self.sub_decisions.update_all(:created_by_user_id => user_id)
        self.icons.update_all(:created_by_user_id => user_id)
        self.graphics.update_all(:created_by_user_id => user_id)
        self.intro_pages.update_all(:created_by_user_id => user_id)
        self.summary_panels.update_all(:created_by_user_id => user_id)
        self.latent_classes.update_all(:created_by_user_id => user_id)
        self.static_pages.update_all(:created_by_user_id => user_id)
        self.skip_logic_targets.update_all(:created_by_user_id => user_id)
        self.skip_logic_conditions.update_all(:created_by_user_id => user_id)
        self.nav_links.update_all(:created_by_user_id => user_id)
        self.accordions.update_all(:user_id => user_id)
        self.data_export_fields.update_all(:created_by_user_id => user_id)
      end
    end
  end

  def sorted_properties(decision_aid_user)
    prop_ids = decision_aid_user.decision_aid_user_properties.pluck(:id)

    if self.decision_aid_type != "best_worst" and self.decision_aid_type != "best_worst_no_results" and self.decision_aid_type != "best_worst_with_prefs_after_choice"
      # 1. joins properties with decision_aid_user_properties where the user is the decision_aid_user
      # 2. select all property attributes and the weight from the user prop
      # 3. order it by the user prop weight, keeping the nulls at the end
      self.properties
        .joins("LEFT OUTER JOIN decision_aid_user_properties ON decision_aid_user_properties.property_id = properties.id AND decision_aid_user_properties.decision_aid_user_id = #{decision_aid_user.id}")
        .select("properties.*, decision_aid_user_properties.weight")
        .order('decision_aid_user_properties.weight DESC NULLS LAST')
    else
      self.properties
        .joins("LEFT OUTER JOIN decision_aid_user_properties ON decision_aid_user_properties.property_id = properties.id AND decision_aid_user_properties.decision_aid_user_id = #{decision_aid_user.id}")
        .select("properties.*, decision_aid_user_properties.traditional_value")
        .order('decision_aid_user_properties.traditional_value DESC NULLS LAST')
    end
  end

  def clone
    # new_da = self.dup
    # self.options.each do |o|
    #   new_o = o.dup
    # end
  end

  def export_user_data(decision_aid_user)
    UserDataExport.new(self, decision_aid_user).export
  end

  def dce_design_fileinfo
    if dce_design_file.exists?
      {
        filename: dce_design_file.original_filename,
        filepath: dce_design_file.url(:original, false)
      }
    else
      nil
    end
  end

  def dce_results_fileinfo
    if dce_results_file.exists?
      {
        filename: dce_results_file.original_filename,
        filepath: dce_results_file.url(:original, false)
      }
    else
      nil
    end
  end

  def bw_design_fileinfo
    if bw_design_file.exists?
      {
        filename: bw_design_file.original_filename,
        filepath: bw_design_file.url(:original, false)
      }
    else
      nil
    end
  end

  def icon_image_name
    icon.image.original_filename unless icon.nil? or !icon.image.exists?
  end

  def footer_logos_with_urls
    logos = Icon.where(id: footer_logos)
    logos.map {|icon| {image_url: url_prefix + icon.image(:original), url: icon.url} }
  end

  def navigation_links
    nav_links = NavLink.where(decision_aid_id: self.id).ordered
    nav_links.map{|nl| {link_text: nl.link_text, link_href: nl.link_href} }
  end

  def footer_logo_images
    if footer_logos.length > 0
      logos = Icon.where(id: footer_logos)
      logos.map {|icon| url_prefix + icon.image(:thumb)}
    else
      []
    end
  end

  def icon_image
    url_prefix + icon.image(:thumb) unless icon.nil? or !icon.image.exists?
  end

  def dce_question_set_count
    dce_question_set_responses.maximum(:question_set)
  end

  def bw_question_set_count
    bw_question_set_responses.maximum(:question_set)
  end

  def clear_user_data
    DecisionAidUser.transaction do
      self.decision_aid_users.destroy_all
    end
  end

  def query_params_length
    if self.decision_aid_query_parameters.reject{|qp| qp.marked_for_destruction? || !qp.is_primary}.length == 0
      errors.add(:decision_aid_query_parameters, "must have at least one primary query param")
    end
  end

  def validate_custom_css
    # TODO
    return
    
    # if !self.custom_css.blank?
    #   validator = CSSValidator.new
    #   results = validator.validate_text(self.custom_css)

    #   if results.errors.length > 0
    #     errors.add(:custom_css, results.errors.first.to_s)
    #   end
    # end
  end

  def validate_dce_colors
    if self.color_rows_based_on_attribute_levels
      if self.dce_min_level_color.blank? or self.dce_max_level_color.blank?
        errors.add(:color_rows_based_on_attribute_levels, "min and max dce colors must be defined")
      end 
    end
  end

  private

  def build_best_worst_hash(dau)
    bwHash = Hash.new
    bw_question_set_responses = dau
      .decision_aid_user_bw_question_set_responses
      .select("decision_aid_user_bw_question_set_responses.best_property_level_id,
               decision_aid_user_bw_question_set_responses.worst_property_level_id")
    self.properties.includes(:property_levels).each do |prop|
      pl = prop.property_levels.first
      if pl
        bestCount = bw_question_set_responses.select{|r| pl.id == r.best_property_level_id}.count
        worstCount = bw_question_set_responses.select{|r| pl.id == r.worst_property_level_id}.count

        bwHash[prop.id] = bestCount - worstCount
      end
    end
    bwHash
  end

  def shift_and_normalize_bw_hash(bw_hash, dau)
    daups = DecisionAidUserProperty.where(decision_aid_user_id: dau.id).index_by {|daup| daup.property_id }
    values = bw_hash.values
    largest_negative = values.min.abs
    largest_positive = values.max + largest_negative
    shifted_hash = Hash.new
    bw_hash.each do |k,v|
      normalized_val = (largest_positive == 0 ? 1.0 / bw_hash.length : (v.to_f + largest_negative.to_f) / largest_positive.to_f)
      if !daups[k].nil?
        daups[k].update_attribute(:traditional_value, normalized_val)
      else
        DecisionAidUserProperty.create!(decision_aid_user_id: dau.id, property_id: k, traditional_value: normalized_val, weight: nil, order: 1, color: "unset")
      end
      shifted_hash[k] = normalized_val
    end
    shifted_hash
  end

  def create_first_sub_decision
    SubDecision.create(decision_aid_id: self.id, created_by_user_id: self.created_by_user_id)
  end

  def create_primary_query_param
    if !self.id
      self.decision_aid_query_parameters_attributes = [{decision_aid_id: self.id, input_name: "pid", output_name: "pid", is_primary: true}]
    end
  end

  def url_prefix
    if RequestStore.store[:protocol] and RequestStore.store[:host_with_port]
      RequestStore.store[:protocol] + RequestStore.store[:host_with_port]
    else
      ""
    end
  end

end
