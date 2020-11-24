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

class DecisionAidSerializer < ActiveModel::Serializer

  attributes :id,
    :title,
    :slug,
    :description,
    :updated_at,
    :created_at,
    :created_by_user_id,
    :is_valid,
    :options_count,
    :properties_count,
    :option_properties_count,
    :demographic_questions_count,
    :quiz_questions_count,
    :question_responses_count,
    :about_information,
    :options_information,
    :properties_information,
    :results_information,
    :quiz_information,
    :property_weight_information,
    :minimum_property_count,
    :maximum_property_count,
    :icon_id,
    :icon_image,
    :footer_logos,
    :footer_logo_images,
    :ratings_enabled,
    :percentages_enabled,
    :best_match_enabled,
    :chart_type,
    :decision_aid_type,
    :dce_information,
    :dce_specific_information,
    :best_worst_information,
    :best_worst_specific_information,
    :dce_question_set_responses_count,
    :bw_question_set_responses_count,
    :dce_design_success,
    :dce_results_success,
    :bw_design_success,
    :dce_design_fileinfo,
    :dce_results_fileinfo,
    :bw_design_fileinfo,
    :other_options_information,
    :creator,
    :theme,
    :has_intro_popup,
    :intro_popup_information,
    :summary_link_to_url,
    :redcap_url,
    :redcap_token,
    :password_protected,
    :access_password,
    :final_summary_text,
    :more_information_button_text,
    :summary_email_addresses,
    :best_wording,
    :worst_wording,
    :include_admin_summary_email,
    :include_user_summary_email,
    :user_summary_email_text,
    :mysql_dbname,
    :mysql_user,
    :mysql_password,
    :contact_email,
    :contact_phone_number,
    :include_download_pdf_button,
    :intro_page_label,
    :about_me_page_label,
    :properties_page_label,
    :quiz_page_label,
    :summary_page_label,
    :results_page_label,
    :best_worst_page_label,
    :icon_image,
    :opt_out_information,
    :properties_auto_submit,
    :opt_out_label,
    :dce_option_prefix,
    :hide_menu_bar,
    :open_summary_link_in_new_tab,
    :color_rows_based_on_attribute_levels,
    :compare_opt_out_to_last_selected,
    :use_latent_class_analysis,
    :language_code,
    :full_width,
    :custom_css,
    :dce_confirmation_question,
    :include_dce_confirmation_question,
    :dce_type,
    :begin_button_text,
    :dce_selection_label,
    :dce_min_level_color,
    :dce_max_level_color,
    :unique_redcap_record_identifier

  has_many :sub_decisions, serializer: SubDecisionSerializer
  has_many :decision_aid_query_parameters, serializer: DecisionAidQueryParameterSerializer

  def icon_image
    object.icon_image
  end

  def is_valid
    all_properties_set = object.option_properties_count == object.options_count * object.properties_count
    isnt_empty = object.option_properties_count > 0 && object.properties_count > 0
    all_properties_set && isnt_empty
  end

  def creator
    "#{object.creator.first_name} #{object.creator.last_name}" if object.creator
  end

end
