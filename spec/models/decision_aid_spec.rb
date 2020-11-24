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

require "rails_helper"

RSpec.describe DecisionAid, :type => :model do

  describe "validations" do
    it "fails to create a decision aid when the slug is nil" do
      decision_aid = build(:basic_decision_aid, slug: nil)

      expect(decision_aid.save).to eq(false)
    end

    it "fails to create a decision aid when the title is nil" do
      decision_aid = build(:basic_decision_aid, title: nil)

      expect(decision_aid.save).to eq(false)
    end

    it "fails to save if no decision aid query parameters exist" do
      decision_aid = build(:basic_decision_aid)
      expect(decision_aid.save).to eq(true)
      decision_aid.decision_aid_query_parameters.destroy_all
      expect(decision_aid.reload.decision_aid_query_parameters.count).to eq(0)
      expect(decision_aid.save).to eq(false)
    end

    it "fails to save if no primary decision aid query parameters exist" do
      decision_aid = build(:basic_decision_aid)
      expect(decision_aid.save).to eq(true)
      expect(decision_aid.reload.decision_aid_query_parameters.count).to eq(1)
      create(:decision_aid_query_parameter, input_name: "input", output_name: "output", is_primary: false, decision_aid_id: decision_aid.id)
      decision_aid.reload.decision_aid_query_parameters.where(is_primary: true).destroy_all
      expect(decision_aid.reload.decision_aid_query_parameters.count).to eq(1)
      expect(decision_aid.save).to eq(false)
    end
  end

  describe "counters" do
    let (:decision_aid) { create(:basic_decision_aid) }
    let (:quiz_question_page) { create(:question_page, decision_aid_id: decision_aid.id, section: "quiz")}
    let (:demo_question_page) { create(:question_page, decision_aid_id: decision_aid.id, section: "about")}

    it "increases/decreases option counter when option is created/deleted" do
      o = build(:option, decision_aid: decision_aid, sub_decision_id: decision_aid.sub_decisions.first.id)
      expect{o.save}.to change{decision_aid.reload.options_count}.by(1)
      expect{o.destroy}.to change{decision_aid.reload.options_count}.by(-1)
    end

    it "increases/decreases property counter when property is created/deleted" do
      p = build(:property, decision_aid: decision_aid)
      expect{p.save}.to change{decision_aid.reload.properties_count}.by(1)
      expect{p.destroy}.to change{decision_aid.reload.properties_count}.by(-1)
    end

    it "increases/decreases option property counter when option property is created/deleted" do
      o = create(:option, decision_aid: decision_aid, sub_decision_id: decision_aid.sub_decisions.first.id)
      p = create(:property, decision_aid: decision_aid)
      op = build(:option_property, decision_aid: decision_aid, property: p, option: o)
      expect{op.save}.to change{decision_aid.reload.option_properties_count}.by(1)
      expect{op.destroy}.to change{decision_aid.reload.option_properties_count}.by(-1)
    end

    it "increases/decreases quiz question counter when quiz question is created/deleted" do
      response_attrs = FactoryGirl.attributes_for(:question_response, decision_aid_id: decision_aid.id, question_response_order: 1)
      q = build(:quiz_radio_question, question_order: 0, decision_aid: decision_aid, question_responses_attributes: [response_attrs], question_page_id: quiz_question_page.id)
      expect{q.save}.to change{decision_aid.reload.quiz_questions_count}.by(1)
      expect{q.destroy}.to change{decision_aid.reload.quiz_questions_count}.by(-1)
    end

    it "increases/decreases demo question counter when demo question is created/deleted" do
      response_attrs = FactoryGirl.attributes_for(:question_response, decision_aid_id: decision_aid.id, question_response_order: 1)
      q = build(:demo_radio_question, question_order: 0, decision_aid: decision_aid, question_responses_attributes: [response_attrs], question_page_id: demo_question_page.id)
      expect{q.save}.to change{decision_aid.reload.demographic_questions_count}.by(1)
      expect{q.destroy}.to change{decision_aid.reload.demographic_questions_count}.by(-1)
    end

    it "increases/decreases question_response counter when question_response is created/deleted" do
      response_attrs = FactoryGirl.attributes_for(:question_response, decision_aid_id: decision_aid.id, question_response_order: 1)
      q = build(:demo_radio_question, question_order: 0, decision_aid: decision_aid, question_responses_attributes: [response_attrs], question_page_id: demo_question_page.id)
      expect{q.save}.to change{decision_aid.reload.question_responses_count}.by(1)
      o = q.question_responses.first
      expect{o.destroy}.to change{decision_aid.reload.question_responses_count}.by(-1)
    end
  end

  describe "callbacks" do
    let (:decision_aid) { create(:full_decision_aid) }

    it "publishes accordion values after saving" do
      expect(decision_aid.description_published).to eq(decision_aid.description)
      expect(decision_aid.about_information_published).to eq(decision_aid.about_information)
      expect(decision_aid.options_information_published).to eq(decision_aid.options_information)
      expect(decision_aid.properties_information_published).to eq(decision_aid.properties_information)
      expect(decision_aid.property_weight_information_published).to eq(decision_aid.property_weight_information)
      expect(decision_aid.results_information_published).to eq(decision_aid.results_information)
      expect(decision_aid.quiz_information_published).to eq(decision_aid.quiz_information)
    end
  end

  describe "assocations" do
    let (:decision_aid) { create(:full_decision_aid) }

    it "has many properties" do
      expect(decision_aid.properties.length).to be > 0
    end

    it "has many options" do
      expect(decision_aid.options.length).to be > 0
    end

    it "has many option properties" do
      expect(decision_aid.option_properties.length).to be > 0
    end

    it "has many demographic and quiz questions" do
      expect(decision_aid.quiz_questions.length).to be > 0
      expect(decision_aid.demographic_questions.length).to be > 0
    end

    it "has many question responses" do
      expect(decision_aid.question_responses.length).to be > 0
    end

    describe "destroys it's children on destroy" do
      it "destroys options" do
        da_options_length = decision_aid.options.length
        expect{ decision_aid.destroy }.to change { Option.count }.by(-da_options_length)
      end

      it "destroys properties" do
        da_properties_length = decision_aid.properties.length
        expect{ decision_aid.destroy }.to change { Property.count }.by(-da_properties_length)
      end

      it "destroys option properties" do
        da_option_properties_length = decision_aid.option_properties.length
        expect{ decision_aid.destroy }.to change { OptionProperty.count }.by(-da_option_properties_length)
      end

      it "destroys questions" do
        da_questions_length = decision_aid.questions.length
        expect{ decision_aid.destroy }.to change { Question.count }.by(-da_questions_length)
      end

      it "destroys questions responses" do
        da_question_responses_length = decision_aid.question_responses.length
        expect{ decision_aid.destroy }.to change { QuestionResponse.count }.by(-da_question_responses_length)
      end
    end
  end

  describe "injectable" do
    it_should_behave_like "injectable", :decision_aid, :basic_decision_aid
  end

  describe "has_attached_items" do
    it_should_behave_like "has_attached_items", :decision_aid, :basic_decision_aid
  end

  describe "user_stamps" do
    it_behaves_like "user_stamps" do
      let (:item) { create(:basic_decision_aid) }
    end
  end

  describe "methods" do
    let (:decision_aid) { create(:full_decision_aid) }

    describe ".relevant_options" do
      it "returns all options if there are no demographic questions" do
        decision_aid_user = create(:decision_aid_user, decision_aid: decision_aid)
        decision_aid.questions.where(question_type: Question.question_types[:demographic]).destroy_all
        decision_aid.save && decision_aid.reload
        expect(decision_aid.relevant_options(decision_aid_user).length).to eq(decision_aid.options.length)
      end

      it "returns all options if no radio questions exist and all questions are answered" do
        decision_aid.questions
          .where(question_type: Question.question_types[:demographic], question_response_type: Question.question_response_types[:radio])
          .destroy_all
        question_ids = decision_aid.demographic_questions.pluck(:id)
        decision_aid_user = create(:decision_aid_user_with_responses, other_question_ids: question_ids, question_ids_hash: {}, decision_aid: decision_aid)
        decision_aid.save && decision_aid.reload
        expect(decision_aid.relevant_options(decision_aid_user).length).to eq(decision_aid.options.length)
      end

      it "filters options based on question response ids" do
        da = decision_aid.reload
        other_question_ids = da.demographic_questions.where.not(question_response_type: Question.question_response_types[:radio]).pluck(:id)
        question_ids_hash = da.demographic_questions.where(question_response_type: Question.question_response_types[:radio]).map {|q| [q[:id], q.question_responses.first.id]}.to_h
        decision_aid_user = create(:decision_aid_user_with_responses, other_question_ids: other_question_ids, question_ids_hash: question_ids_hash, decision_aid: da)


        expect(da.relevant_options(decision_aid_user).length).to eq(da.options.length)
        o = create(:option, decision_aid: da, sub_decision_id: decision_aid.sub_decisions.first.id)
        relevant_options = da.reload.relevant_options(decision_aid_user)
        expect(da.options).to include(o)
        expect(relevant_options.length).not_to eq(da.options.length)
        expect(relevant_options).not_to include(o)
      end

      it "filters options using passed in response ids despite empty decision aid user responses" do
        decision_aid_user = create(:decision_aid_user, decision_aid: decision_aid)
        response_ids = decision_aid.demographic_questions.where(question_response_type: Question.question_response_types[:radio]).includes(:question_responses).map {|q| q.question_responses.first.id}
        expect(decision_aid.relevant_options(decision_aid_user, response_ids).length).to eq(decision_aid.options.length)
      end

      describe "current_treatment sorting" do
        let! (:decision_aid) { create(:basic_decision_aid) }
        let! (:o1) { create(:option, decision_aid: decision_aid, sub_decision_id: decision_aid.sub_decisions.first.id) }
        let! (:o2) { create(:option, decision_aid: decision_aid, sub_decision_id: decision_aid.sub_decisions.first.id) }
        let! (:current_treatment_question) { create(:demo_current_treatment_question, decision_aid_id: decision_aid.id, sub_decision_id: decision_aid.sub_decisions.first.id) }
        let! (:decision_aid_user) { create(:decision_aid_user, decision_aid: decision_aid) }
        let! (:response) { create(:decision_aid_user_response, decision_aid_user_id: decision_aid_user.id, question_id: current_treatment_question.id, option_id: o2.id) }
        
        it "shows current treatment option first if such a response exists" do
          options = decision_aid.reload.relevant_options(decision_aid_user, nil, decision_aid.sub_decisions.first.id)
          expect(options.first.id).to equal o2.id
          response.option_id = o1.id
          response.save
          options = decision_aid.reload.relevant_options(decision_aid_user, nil, decision_aid.sub_decisions.first.id)
          expect(options.first.id).to equal o1.id
        end
      end
    end

    describe ".sorted_properties" do
      it "keeps null properties at the end of the list" do
        props = decision_aid.properties
        question_ids_hash = decision_aid.demographic_questions.where(question_response_type: Question.question_response_types[:radio]).map {|q| [q[:id], q.question_responses.first.id]}.to_h
        property_id_weights = {props[0].id => 45, props[1].id => 65, props[2].id => 53}
        decision_aid_user = create(:decision_aid_user_with_properties, property_hash: property_id_weights, question_ids_hash: question_ids_hash, decision_aid: decision_aid)
        sorted_props = decision_aid.sorted_properties(decision_aid_user)
        starting_index = question_ids_hash.length

        expect(sorted_props.length).to eq(props.length)
        expect(starting_index).not_to eq(sorted_props.length-1)

        while starting_index < sorted_props.length
          expect(property_id_weights[sorted_props[starting_index].id]).to be_nil
          starting_index += 1
        end
      end

      it "sorts properties based on weights" do
        props = decision_aid.properties
        property_id_weights = props.each_with_index.map {|p, index| [p[:id], index+1]}.to_h
        property_id_weights_2 = props.each_with_index.map {|p, index| [p[:id], 100-index]}.to_h
        question_ids_hash = decision_aid.demographic_questions.where(question_response_type: 0).map {|q| [q[:id], q.question_responses.first.id]}.to_h
        decision_aid_user = create(:decision_aid_user_with_properties, property_hash: property_id_weights, question_ids_hash: question_ids_hash, decision_aid: decision_aid)
        sorted_props = decision_aid.sorted_properties(decision_aid_user)
        decision_aid_user_2 = create(:decision_aid_user_with_properties, property_hash: property_id_weights_2, question_ids_hash: question_ids_hash, decision_aid: decision_aid)
        sorted_props_2 = decision_aid.sorted_properties(decision_aid_user_2)
        
        props.each_with_index do |p, index|
          expect(sorted_props[props.length - index - 1]).to eq(p)
          expect(sorted_props_2[index]).to eq(p)
        end
      end
    end

    describe ".option_match_from_standard" do
      let (:dau) { create(:decision_aid_user, decision_aid: decision_aid) }

      it "should return an empty object if no sub decision provided" do
        option_matches = decision_aid.option_match_from_standard(dau, nil)
        expect(option_matches).to be_empty
      end

      it "should select the last option as the best match" do
        decision_aid.properties.ordered.each do |prop|
          create(:decision_aid_user_property, decision_aid_user_id: dau.id, property_id: prop.id, weight: 1)

          decision_aid.options.ordered.each_with_index do |opt, i|
            op = OptionProperty.find_by(option_id: opt.id, property_id: prop.id)
            create(:decision_aid_user_option_property, decision_aid_user_id: dau.id, 
                                                       option_property_id: op.id,
                                                       property_id: op.property_id,
                                                       option_id: op.option_id,
                                                       value: i+1)
          end
        end

        option_matches = decision_aid.option_match_from_standard(dau, decision_aid.sub_decisions.ordered.first.sub_decision_order)
        max = option_matches.max_by{|k,v| v}
        expect(max[0]).to be decision_aid.options.ordered.last.id
      end 

      it "should ignore option properties where option weights are 0" do
        decision_aid.properties.ordered.each do |prop|
          create(:decision_aid_user_property, decision_aid_user_id: dau.id, property_id: prop.id, weight: 1)

          decision_aid.options.ordered.each_with_index do |opt, i|
            op = OptionProperty.find_by(option_id: opt.id, property_id: prop.id)
            
            value_to_use = ( i == decision_aid.options.length - 1 ? 0 : i + 1 )

            create(:decision_aid_user_option_property, decision_aid_user_id: dau.id, 
                                                       option_property_id: op.id,
                                                       property_id: op.property_id,
                                                       option_id: op.option_id,
                                                       value: value_to_use)
          end
        end

        option_matches = decision_aid.option_match_from_standard(dau, decision_aid.sub_decisions.ordered.first.sub_decision_order)
        max = option_matches.max_by{|k,v| v}
        expect(max[0]).to be decision_aid.options.ordered.last(2).first.id
      end

      it "should use predefined option property weights if are_option_properties_weighable is set to false" do
        decision_aid.properties.ordered.each_with_index do |prop, i|
          if i == 0
            prop.are_option_properties_weighable = false
            prop.save
          end
          create(:decision_aid_user_property, decision_aid_user_id: dau.id, property_id: prop.id, weight: 1)

          decision_aid.options.ordered.each_with_index do |opt, ii|
            op = OptionProperty.find_by(option_id: opt.id, property_id: prop.id)
            if ii == 0
              op.ranking_type = "integer"
              op.ranking = (decision_aid.options.length - ii) * 10
              op.save!
            end
            create(:decision_aid_user_option_property, decision_aid_user_id: dau.id, 
                                                       option_property_id: op.id,
                                                       property_id: op.property_id,
                                                       option_id: op.option_id,
                                                       value: ii+1)
          end
        end

        option_matches = decision_aid.option_match_from_standard(dau, decision_aid.sub_decisions.ordered.first.sub_decision_order)
        max = option_matches.max_by{|k,v| v}
        expect(max[0]).to be decision_aid.options.ordered.first.id
      end
    end

    describe ".option_match_from_treatment_rankings" do
      let (:dau) { create(:decision_aid_user, decision_aid: decision_aid) }

      it "should return an empty object if no sub decision provided" do
        option_matches = decision_aid.option_match_from_treatment_rankings(dau, nil)
        expect(option_matches).to be_empty
      end

      it "should select the last option as the best match" do
        decision_aid.properties.ordered.each do |prop|
          create(:decision_aid_user_property, decision_aid_user_id: dau.id, property_id: prop.id, weight: 1)

          decision_aid.options.ordered.each_with_index do |opt, i|
            op = OptionProperty.find_by(option_id: opt.id, property_id: prop.id)
            op.ranking_type = "integer"
            op.ranking = i + 1
            op.save!

            create(:decision_aid_user_option_property, decision_aid_user_id: dau.id, 
                                                       option_property_id: op.id,
                                                       property_id: op.property_id,
                                                       option_id: op.option_id)
          end
        end

        option_matches = decision_aid.option_match_from_treatment_rankings(dau, decision_aid.sub_decisions.ordered.first.sub_decision_order)
        max = option_matches.max_by{|k,v| v}
        expect(max[0]).to be decision_aid.options.ordered.last.id
      end 

      it "should not use weights defined on the decision_aid_user_option_property" do
        decision_aid.properties.ordered.each do |prop|
          create(:decision_aid_user_property, decision_aid_user_id: dau.id, property_id: prop.id, weight: 1)

          decision_aid.options.ordered.each_with_index do |opt, i|
            op = OptionProperty.find_by(option_id: opt.id, property_id: prop.id)
            op.ranking_type = "integer"
            op.ranking = (decision_aid.options.length - i)
            op.save!

            create(:decision_aid_user_option_property, decision_aid_user_id: dau.id, 
                                                       option_property_id: op.id,
                                                       property_id: op.property_id,
                                                       option_id: op.option_id,
                                                       value: 2 * (i + 1))
          end
        end

        option_matches = decision_aid.option_match_from_treatment_rankings(dau, decision_aid.sub_decisions.ordered.first.sub_decision_order)
        max = option_matches.max_by{|k,v| v}
        expect(max[0]).to be decision_aid.options.ordered.first.id
      end 
    end

    describe ".option_match_from_dce" do
      let! (:dce_results_match) { create(:dce_results_match, decision_aid_id: decision_aid.id, response_combination: [1,1,1], option_match_hash: {[] => {decision_aid.options.first.id => 0.5}}) }
      let! (:dau) { create(:decision_aid_user, decision_aid: decision_aid) }
      let! (:dr1) { create(:dce_question_set_response, question_set: 1, response_value: 1, decision_aid_id: decision_aid.id, property_level_hash: {1 => 1}) }
      let! (:dr2) { create(:dce_question_set_response, question_set: 1, response_value: 2, decision_aid_id: decision_aid.id, property_level_hash: {1 => 1}) }
      let! (:dr3) { create(:dce_question_set_response, question_set: 2, response_value: 1, decision_aid_id: decision_aid.id, property_level_hash: {1 => 1}) }
      let! (:dr4) { create(:dce_question_set_response, question_set: 2, response_value: 2, decision_aid_id: decision_aid.id, property_level_hash: {1 => 1}) }
      let! (:dr5) { create(:dce_question_set_response, question_set: 3, response_value: 1, decision_aid_id: decision_aid.id, property_level_hash: {1 => 1}) }
      let! (:dr6) { create(:dce_question_set_response, question_set: 3, response_value: 2, decision_aid_id: decision_aid.id, property_level_hash: {1 => 1}) }
      let! (:r1) { create(:decision_aid_user_dce_question_set_response, decision_aid_user_id: dau.id, dce_question_set_response_id: dr1.id, question_set: 1) }
      let! (:r2) { create(:decision_aid_user_dce_question_set_response, decision_aid_user_id: dau.id, dce_question_set_response_id: dr3.id, question_set: 2) }
      let! (:r3) { create(:decision_aid_user_dce_question_set_response, decision_aid_user_id: dau.id, dce_question_set_response_id: dr5.id, question_set: 3) }

      it "returns nil if there is no option match found" do
        r1.dce_question_set_response_id = dr2.id
        r1.save
        o = decision_aid.option_match_from_dce(dau)
        expect(o).to be nil
      end

      it "returns an option if a match is found" do
        o = decision_aid.option_match_from_dce(dau)
        expect(o).to eq({decision_aid.options.first.id.to_s => 0.5})
      end
    end

    describe ".change_ownership" do 
      let (:u1) {create(:user, email: "123@abc.com")}
      let (:u2) {create(:user, email: "456@abc.com")}

      it "should change ownership from u1 to u2" do
        decision_aid.change_ownership(u1.id)
        expect(decision_aid.creator.id).to be u1.id
        decision_aid.change_ownership(u2.id)
        expect(decision_aid.creator.id).to be u2.id
      end

      it "should not change ownership if user doesnt exist" do
        fake_user_id = -1
        decision_aid.change_ownership(u1.id)
        expect(decision_aid.creator.id).to be u1.id
        decision_aid.change_ownership(fake_user_id)

        expect(decision_aid.creator.id).not_to be fake_user_id
      end
    end

    describe ".dce_question_set_count" do

      it "should return nil if no question sets exist" do
        expect(decision_aid.dce_question_set_count).to be nil
      end

      it "should return the maximum question set" do
        create(:dce_question_set_response, question_set: 1, response_value: 1, decision_aid_id: decision_aid.id, property_level_hash: {1 => 1})
        create(:dce_question_set_response, question_set: 1, response_value: 2, decision_aid_id: decision_aid.id, property_level_hash: {1 => 1})
        create(:dce_question_set_response, question_set: 2, response_value: 1, decision_aid_id: decision_aid.id, property_level_hash: {1 => 1})
        create(:dce_question_set_response, question_set: 2, response_value: 2, decision_aid_id: decision_aid.id, property_level_hash: {1 => 1})
        create(:dce_question_set_response, question_set: 3, response_value: 1, decision_aid_id: decision_aid.id, property_level_hash: {1 => 1})
        create(:dce_question_set_response, question_set: 3, response_value: 2, decision_aid_id: decision_aid.id, property_level_hash: {1 => 1})
        expect(decision_aid.dce_question_set_count).to eq 3
      end
    end
  end

  describe ".option_match_from_best_worst" do
    let (:decision_aid) { create(:full_decision_aid) }
    let (:dau) { create(:decision_aid_user, decision_aid: decision_aid) }

    before do
      # destroy demographic questions so that all options are retrieved from relevant_options
      decision_aid.questions.where(question_type: Question.question_types[:demographic]).destroy_all
      decision_aid.reload
      decision_aid.properties.ordered.each do |p|
        create(:property_level, property_id: p.id, decision_aid_id: decision_aid.id, level_id: 1)
      end
    end 

    describe "using latent class analysis" do
      let (:lc1) { create(:latent_class, decision_aid_id: decision_aid.id) }
      let (:lc2) { create(:latent_class, decision_aid_id: decision_aid.id) }

      before do
        decision_aid.use_latent_class_analysis = true
        decision_aid.save!
        
        decision_aid.properties.ordered.each_with_index do |p, i|
          create(:latent_class_property, property_id: p.id, latent_class_id: lc1.id, weight: i)
          create(:latent_class_property, property_id: p.id, latent_class_id: lc2.id, weight: decision_aid.properties.length-i)
        end

        weights = [2,8,40,50]
        decision_aid.options.ordered.each_with_index do |o, i|
          create(:latent_class_option, option_id: o.id, latent_class_id: lc1.id, weight: weights[decision_aid.options.length-i-1])
          create(:latent_class_option, option_id: o.id, latent_class_id: lc2.id, weight: weights[i])
        end
      end

      it "should match the last option when the first property is always the most important (matches first latent class)" do
        decision_aid.properties.ordered.each_with_index do |p, i|
          create(:decision_aid_user_bw_question_set_response, 
            best_property_level_id: decision_aid.properties.ordered.first.property_levels.first.id, 
            worst_property_level_id: decision_aid.properties.ordered.last.property_levels.first.id, 
            question_set: i+1, 
            decision_aid_user_id: dau.id, 
            bw_question_set_response_id: -1
          )
        end

        option_matches = decision_aid.option_match_from_best_worst(dau, decision_aid.sub_decisions.first.id)
        max = option_matches.max_by{|k,v| v}
        expect(max[0]).to be decision_aid.options.ordered.last.id
      end

      it "should match the first option when the last property is always the most important (matches second latent class)" do
        decision_aid.properties.ordered.each_with_index do |p, i|
          create(:decision_aid_user_bw_question_set_response, 
            best_property_level_id: decision_aid.properties.ordered.last.property_levels.first.id, 
            worst_property_level_id: decision_aid.properties.ordered.first.property_levels.first.id, 
            question_set: i+1, 
            decision_aid_user_id: dau.id, 
            bw_question_set_response_id: -1
          )
        end

        option_matches = decision_aid.option_match_from_best_worst(dau, decision_aid.sub_decisions.first.id)
        max = option_matches.max_by{|k,v| v}
        expect(max[0]).to be decision_aid.options.ordered.first.id
      end
    end

    describe "equal scores" do
      
      before do
        op_hash = decision_aid.option_properties.index_by {|op| "#{op.option_id}-#{op.property_id}"}
        decision_aid.properties.ordered.each do |p|
          decision_aid.options.ordered.each do |o|
            op = op_hash["#{o.id}-#{p.id}"]
            op.ranking_type = "integer"
            op.ranking = 3
            op.save
          end
        end
      end 
    
      it "should return a hash with equal percentages when attributes are selected at best and worst equal number of times" do
        create(:decision_aid_user_bw_question_set_response, 
               best_property_level_id: decision_aid.property_levels.first.id, 
               worst_property_level_id: decision_aid.property_levels.second.id, 
               question_set: 1, 
               decision_aid_user_id: dau.id, 
               bw_question_set_response_id: -1)
        create(:decision_aid_user_bw_question_set_response, 
               best_property_level_id: decision_aid.property_levels.second.id, 
               worst_property_level_id: decision_aid.property_levels.first.id, 
               question_set: 2, 
               decision_aid_user_id: dau.id, 
               bw_question_set_response_id: -1)

        decision_aid.reload

        r = decision_aid.option_match_from_best_worst(dau, decision_aid.sub_decisions.first.id)
        expect(r.length).to be > 0
        expect(r.values.uniq.length).to eq(1)
      end
    end

    describe "unequal scores" do

      before do
        op_hash = decision_aid.option_properties.index_by {|op| "#{op.option_id}-#{op.property_id}"}
        decision_aid.properties.ordered.each do |p|
          decision_aid.options.ordered.each_with_index do |o, i|
            op = op_hash["#{o.id}-#{p.id}"]
            op.ranking_type = "integer"
            op.ranking = i + 1
            op.save
          end
        end
      end

      it "should return a hash with the best option having the highest percentage" do
        create(:decision_aid_user_bw_question_set_response, 
               best_property_level_id: decision_aid.property_levels.first.id, 
               worst_property_level_id: decision_aid.property_levels.second.id, 
               question_set: 1, 
               decision_aid_user_id: dau.id, 
               bw_question_set_response_id: -1)
        create(:decision_aid_user_bw_question_set_response, 
               best_property_level_id: decision_aid.property_levels.second.id, 
               worst_property_level_id: decision_aid.property_levels.first.id, 
               question_set: 3, 
               decision_aid_user_id: dau.id, 
               bw_question_set_response_id: -1)

        decision_aid.reload
        # the last option has the highest ranking, so it should be the winner
        r = decision_aid.option_match_from_best_worst(dau, decision_aid.sub_decisions.first.id)
        expect(r.length).to be > 0
        last_option = decision_aid.options.ordered.last
        expect(r.max_by{|k,v| v}.first).to eq(last_option.id)
      end

      it "should return a hash with the best option having the highest percentage best_worst scaled" do
        o = decision_aid.options.ordered.last
        fo = decision_aid.options.ordered.first
        p = decision_aid.properties.ordered.first
        lp = decision_aid.properties.ordered.last
        mp = decision_aid.properties.ordered.second

        decision_aid.option_properties.update_all(ranking: 1)

        op1 = OptionProperty.where(decision_aid_id: decision_aid.id, option_id: o.id, property_id: p.id).take
        op2 = OptionProperty.where(decision_aid_id: decision_aid.id, option_id: fo.id, property_id: lp.id).take

        op1.update_attributes!(:ranking => "4", ranking_type: "integer")
        op2.update_attributes!(:ranking => "5", ranking_type: "integer")

        create(:decision_aid_user_bw_question_set_response, 
               best_property_level_id: p.property_levels.first.id, 
               worst_property_level_id: lp.property_levels.first.id, 
               question_set: 1, 
               decision_aid_user_id: dau.id, 
               bw_question_set_response_id: -1)
        create(:decision_aid_user_bw_question_set_response, 
               best_property_level_id: p.property_levels.first.id, 
               worst_property_level_id: mp.property_levels.first.id, 
               question_set: 2, 
               decision_aid_user_id: dau.id, 
               bw_question_set_response_id: -1)
        create(:decision_aid_user_bw_question_set_response, 
               best_property_level_id: p.property_levels.first.id, 
               worst_property_level_id: mp.property_levels.first.id, 
               question_set: 3, 
               decision_aid_user_id: dau.id, 
               bw_question_set_response_id: -1)
        create(:decision_aid_user_bw_question_set_response, 
               best_property_level_id: lp.property_levels.first.id, 
               worst_property_level_id: p.property_levels.first.id, 
               question_set: 4, 
               decision_aid_user_id: dau.id, 
               bw_question_set_response_id: -1)

        decision_aid.reload

        # o should beat fo due to better best_worst score
        r = decision_aid.option_match_from_best_worst(dau, decision_aid.sub_decisions.first.id)
        expect(r.length).to be > 0
        expect(r.max_by{|k,v| v}.first).to eq(o.id)
      end
    end
  end
end
