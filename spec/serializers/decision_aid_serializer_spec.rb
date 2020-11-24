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

require 'rails_helper'

RSpec.describe DecisionAidSerializer, :type => :serializer do

  context 'decision aid representation' do
    let(:decision_aid) { build(:basic_decision_aid) }

    let(:serializer) { DecisionAidSerializer.new(decision_aid) }
    let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }

    subject do
      JSON.parse(serialization.to_json)['decision_aid']
    end

    it 'has an id key' do
      expect(subject).to have_key 'id'
    end

    it 'has a title key' do
      expect(subject).to have_key 'title'
    end

    it 'has a slug key' do
      expect(subject).to have_key 'slug'
    end

    it 'has a description key' do
      expect(subject).to have_key 'description'
    end

    it 'has an updated_at key' do
      expect(subject).to have_key 'updated_at'
    end

    it 'has a created_at key' do
      expect(subject).to have_key 'created_at'
    end

    it 'has a created_by_user_id key' do
      expect(subject).to have_key 'created_by_user_id'
    end

    it 'has an is_valid key' do
      expect(subject).to have_key 'is_valid'
    end

    it 'has an options_count key' do
      expect(subject).to have_key 'options_count'
    end

    it 'has a properties_count key' do
      expect(subject).to have_key 'properties_count'
    end

    it 'has a demographic_questions_count key' do
      expect(subject).to have_key 'demographic_questions_count'
    end

    it 'has a quiz_questions_count key' do
      expect(subject).to have_key 'quiz_questions_count'
    end

    it 'has a question_responses_count key' do
      expect(subject).to have_key 'question_responses_count'
    end

    it 'has an about_information key' do
      expect(subject).to have_key 'about_information'
    end

    it 'has an options_information key' do
      expect(subject).to have_key 'options_information'
    end

    it 'has a properties_information key' do
      expect(subject).to have_key 'properties_information'
    end

    it 'has a results_information key' do
      expect(subject).to have_key 'about_information'
    end

    it 'has a quiz_information key' do
      expect(subject).to have_key 'quiz_information'
    end

    it 'has a property_weight_information key' do
      expect(subject).to have_key 'property_weight_information'
    end

    it 'has a minimum_property_count key' do
      expect(subject).to have_key 'minimum_property_count'
    end

    it 'has an icon_id key' do
      expect(subject).to have_key 'icon_id'
    end

    it 'has an icon_image key' do
      expect(subject).to have_key 'icon_image'
    end

    it 'has a footer_logos key' do
      expect(subject).to have_key 'about_information'
    end

    it 'has a footer_logo_images key' do
      expect(subject).to have_key 'footer_logo_images'
    end

    it 'has a ratings_enabled key' do
      expect(subject).to have_key 'ratings_enabled'
    end

    it 'has a percentages_enabled key' do
      expect(subject).to have_key 'percentages_enabled'
    end

    it 'has a best_match_enabled key' do
      expect(subject).to have_key 'best_match_enabled'
    end

    it 'has a chart_type key' do
      expect(subject).to have_key 'chart_type'
    end

    it 'has a decision_aid_type key' do
      expect(subject).to have_key 'decision_aid_type'
    end

    it 'has a dce_information key' do
      expect(subject).to have_key 'dce_information'
    end

    it 'has a dce_specific_information key' do
      expect(subject).to have_key 'dce_specific_information'
    end

    it 'has a best_worst_information key' do
      expect(subject).to have_key 'best_worst_information'
    end

    it 'has a best_worst_specific_information key' do
      expect(subject).to have_key 'best_worst_specific_information'
    end

    it 'has a dce_question_set_responses_count key' do
      expect(subject).to have_key 'dce_question_set_responses_count'
    end

    it 'has a bw_question_set_responses_count key' do
      expect(subject).to have_key 'bw_question_set_responses_count'
    end

    it 'has a dce_design_success key' do
      expect(subject).to have_key 'dce_design_success'
    end

    it 'has a dce_results_success key' do
      expect(subject).to have_key 'dce_results_success'
    end

    it 'has a bw_design_success key' do
      expect(subject).to have_key 'bw_design_success'
    end

    it 'has a dce_design_fileinfo key' do
      expect(subject).to have_key 'dce_design_fileinfo'
    end

    it 'has a dce_results_fileinfo key' do
      expect(subject).to have_key 'dce_results_fileinfo'
    end

    it 'has a bw_design_fileinfo key' do
      expect(subject).to have_key 'bw_design_fileinfo'
    end

    it 'has an other_options_information key' do
      expect(subject).to have_key 'other_options_information'
    end

    it 'has a creator key' do
      expect(subject).to have_key 'creator'
    end
  end
end
