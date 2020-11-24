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

FactoryGirl.define do
  factory :basic_decision_aid, class: DecisionAid do
    sequence(:slug){|n| "knee_pain_#{n}"}
    title "Knee Pain"
    decision_aid_type "standard"

    # before(:create) do |decision_aid, evaluator|
    #   decision_aid.decision_aid_query_parameters_attributes = [FactoryGirl.attributes_for(:decision_aid_query_parameter)]
    #   #[{decision_aid: decision_aid, input_name: "pid", output_name: "pid", is_primary: true}]
    # end

    after(:create) do |decision_aid, evaluator|
      create(:intro_page, description: "Knee Pain Description", decision_aid_id: decision_aid.id)
    end

    factory :full_decision_aid, class: DecisionAid do
      about_information "About information"
      options_information "Options information"
      properties_information "Properties information"
      property_weight_information "Property weight information"
      results_information "Results information"
      quiz_information "Quiz information"
      minimum_property_count 2

      transient do
        properties_count 4
        options_count 4
        quiz_radio_questions_count 4
        demographic_radio_questions_count 4
        quiz_text_questions_count 4
        demographic_text_questions_count 4
      end

      after(:create) do |decision_aid, evaluator|
        #sd = create(:sub_decision, decision_aid: decision_aid, sub_decision_order: 1)

        demographic_questions = []
        0.upto(evaluator.demographic_radio_questions_count-1) do |i|
          demographic_questions.push create(:demo_radio_question, question_order: i, decision_aid: decision_aid)
        end
        0.upto(evaluator.demographic_text_questions_count-1) do |i|
          demographic_questions.push create(:demo_text_question, question_order: i, decision_aid: decision_aid)
        end 

        quiz_questions = []
        0.upto(evaluator.quiz_radio_questions_count-1) do |i|
          quiz_questions.push create(:quiz_radio_question, question_order: i, decision_aid: decision_aid)
        end
        0.upto(evaluator.quiz_text_questions_count-1) do |i|
          quiz_questions.push create(:quiz_text_question, question_order: i, decision_aid: decision_aid)
        end

        props = create_list(:property, evaluator.properties_count, decision_aid: decision_aid)
        options = create_list(:option, evaluator.options_count, sub_decision_id: decision_aid.sub_decisions.first.id, decision_aid: decision_aid, question_response_array: demographic_questions.select{|q| q.question_response_type == "radio"}.map{|q| q.question_responses.first.id})
        props.each do |prop|
          options.each do |option|
            create(:option_property, option: option, property: prop, decision_aid: decision_aid)
          end
        end
      end

      factory :full_decision_aid_with_sub_decisions, class: DecisionAid do
        after(:create) do |decision_aid, evaluator|
          sd = create(:sub_decision, decision_aid_id: decision_aid.id, sub_decision_order: 2, required_option_ids: decision_aid.options.ordered[0..decision_aid.options.ordered.count-2].map{|o| o.id})
          options = create_list(:option, evaluator.options_count, sub_decision_id: sd.id, decision_aid: decision_aid, question_response_array: decision_aid.demographic_questions.select{|q| q.question_response_type == "radio"}.map{|q| q.question_responses.first.id})
        end
      end
    end

    factory :dce_decision_aid, class: DecisionAid do
      decision_aid_type "dce"

      about_information "About information"
      options_information "Options information"
      dce_information "DCE Information"
      dce_specific_information "DCE Specific Information"
      results_information "Results information"
      quiz_information "Quiz information"
      minimum_property_count 2

      transient do
        properties_count 4
        options_count 4
        quiz_radio_questions_count 4
        demographic_radio_questions_count 4
        quiz_text_questions_count 4
        demographic_text_questions_count 4
      end

      after(:create) do |decision_aid, evaluator|

        #sd = create(:sub_decision, decision_aid: decision_aid, sub_decision_order: 1)

        demographic_questions = []
        0.upto(evaluator.demographic_radio_questions_count-1) do |i|
          demographic_questions.push create(:demo_radio_question, question_order: i+1, decision_aid: decision_aid)
        end
        0.upto(evaluator.demographic_text_questions_count-1) do |i|
          demographic_questions.push create(:demo_text_question, question_order: i+1, decision_aid: decision_aid)
        end 

        props = create_list(:property_with_levels, evaluator.properties_count, decision_aid: decision_aid)
        options = create_list(:option, evaluator.options_count, sub_decision_id: decision_aid.sub_decisions.first.id, decision_aid: decision_aid, question_response_array: demographic_questions.select{|q| q.question_response_type == "radio"}.map{|q| q.question_responses.first.id})
        props.each do |prop|
          options.each do |option|
            create(:option_property, option: option, property: prop, decision_aid: decision_aid)
          end
        end

        valid_design_csv = 
          "question_set,answer,block, ,#{props.map(&:title).join(",")}
            , , ,ID,#{props.map(&:id).join(",")}
            , , ,Maximum Value,#{props.map{|p| p.property_levels.count}.join(",")}
            1,1,1, ,#{[*1..props.length].join(",")}
            1,2,1, ,#{[*1..props.length].reverse.join(",")}
            2,1,1, ,#{[*1..props.length].join(",")}
            2,2,1, ,#{[*1..props.length].reverse.join(",")}
            3,1,1, ,#{[*1..props.length].join(",")}
            3,2,1, ,#{[*1..props.length].reverse.join(",")}
            4,1,1, ,#{[*1..props.length].join(",")}
            4,2,1, ,#{[*1..props.length].reverse.join(",")}
            5,1,1, ,#{[*1..props.length].join(",")}
            5,2,1, ,#{[*1..props.length].reverse.join(",")}"

        design_file = StringIO.new(valid_design_csv)
        decision_aid.dce_design_file = design_file

        valid_results_csv = 
          " , , , , ,weights,#{Array.new(props.length, " ").join(",")},ID,#{options.map(&:id).join(",")}
          question_set_1,question_set_2,question_set_3,question_set_4,question_set_5,#{props.map(&:title).join(",")}, ,Option Name,#{options.map(&:title).join(",")}
          1,1,1,1,1,#{Array.new(props.length+2, " ").join(",")}, ,1
          1,1,1,1,2,#{Array.new(props.length+2, " ").join(",")}, ,1
          1,1,1,2,1,#{Array.new(props.length+2, " ").join(",")}, ,1
          1,1,1,2,2,#{Array.new(props.length+2, " ").join(",")}, ,1
          1,1,2,1,1,#{Array.new(props.length+2, " ").join(",")}, ,1
          1,1,2,1,2,#{Array.new(props.length+2, " ").join(",")}, ,1
          1,1,2,2,1,#{Array.new(props.length+2, " ").join(",")}, ,1
          1,1,2,2,2,#{Array.new(props.length+2, " ").join(",")}, ,1
          1,2,1,1,1,#{Array.new(props.length+2, " ").join(",")}, ,1
          1,2,1,1,2,#{Array.new(props.length+2, " ").join(",")}, ,1
          1,2,1,2,1,#{Array.new(props.length+2, " ").join(",")}, ,1
          1,2,1,2,2,#{Array.new(props.length+2, " ").join(",")}, ,1
          1,2,2,1,1,#{Array.new(props.length+2, " ").join(",")}, ,1
          1,2,2,1,2,#{Array.new(props.length+2, " ").join(",")}, ,1
          1,2,2,2,1,#{Array.new(props.length+2, " ").join(",")}, ,1
          1,2,2,2,2,#{Array.new(props.length+2, " ").join(",")}, ,1
          2,1,1,1,1,#{Array.new(props.length+2, " ").join(",")}, ,1
          2,1,1,1,2,#{Array.new(props.length+2, " ").join(",")}, ,1
          2,1,1,2,1,#{Array.new(props.length+2, " ").join(",")}, ,1
          2,1,1,2,2,#{Array.new(props.length+2, " ").join(",")}, ,1
          2,1,2,1,1,#{Array.new(props.length+2, " ").join(",")}, ,1
          2,1,2,1,2,#{Array.new(props.length+2, " ").join(",")}, ,1
          2,1,2,2,1,#{Array.new(props.length+2, " ").join(",")}, ,1
          2,1,2,2,2,#{Array.new(props.length+2, " ").join(",")}, ,1
          2,2,1,1,1,#{Array.new(props.length+2, " ").join(",")}, ,1
          2,2,1,1,2,#{Array.new(props.length+2, " ").join(",")}, ,1
          2,2,1,2,1,#{Array.new(props.length+2, " ").join(",")}, ,1
          2,2,1,2,2,#{Array.new(props.length+2, " ").join(",")}, ,1
          2,2,2,1,1,#{Array.new(props.length+2, " ").join(",")}, ,1
          2,2,2,1,2,#{Array.new(props.length+2, " ").join(",")}, ,1
          2,2,2,2,1,#{Array.new(props.length+2, " ").join(",")}, ,1
          2,2,2,2,2,#{Array.new(props.length+2, " ").join(",")}, ,1"

        results_file = StringIO.new(valid_results_csv)
        decision_aid.dce_results_file = results_file

        decision_aid.save

        DceImport.new(decision_aid, 1).import_design
        DceImport.new(decision_aid, 1).import_results

        quiz_questions = []
        0.upto(evaluator.quiz_radio_questions_count-1) do |i|
          quiz_questions.push create(:quiz_radio_question, question_order: i+1, decision_aid: decision_aid)
        end
        0.upto(evaluator.quiz_text_questions_count-1) do |i|
          quiz_questions.push create(:quiz_text_question, question_order: i+1, decision_aid: decision_aid)
        end
      end
    end
  end
end
