# == Schema Information
#
# Table name: data_export_fields
#
#  id                      :integer          not null, primary key
#  exporter_id             :integer          not null
#  exporter_type           :string           not null
#  decision_aid_id         :integer          not null
#  data_target_type        :integer          not null
#  data_export_field_order :integer          not null
#  redcap_field_name       :string
#  redcap_response_mapping :json
#  created_by_user_id      :integer
#  updated_by_user_id      :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  data_accessor           :string
#

require 'rails_helper'

RSpec.describe DataExportField, type: :model do
  let (:decision_aid) { create(:basic_decision_aid, slug: "test_decision_aid") }
  let (:question) { create(:demo_text_question, decision_aid: decision_aid) }

  describe "validations" do
    describe "general" do
      it "should save if all required attributes are set" do
        data_export_field = build(:data_export_field, decision_aid_id: decision_aid.id,
                                                      exporter_id: question.id,
                                                      exporter_type: question.class.to_s,
                                                      data_target_type: "redcap",
                                                      redcap_field_name: "test_redcap_field")
        expect(data_export_field.save).to be true
      end

      it "should fail to save if decision_aid is missing" do
        data_export_field = build(:data_export_field, exporter_id: question.id,
                                                      exporter_type: question.class.to_s,
                                                      data_target_type: "redcap",
                                                      redcap_field_name: "test_redcap_field",
                                                      data_export_field_order: 1)
        expect(data_export_field.save).to be false
        expect(data_export_field.errors.messages).to have_key :decision_aid_id
      end

      it "should fail to save if exporter_type is missing" do
        data_export_field = build(:data_export_field, decision_aid_id: decision_aid.id,
                                                      exporter_id: question.id,
                                                      data_target_type: "redcap",
                                                      redcap_field_name: "test_redcap_field")
        expect(data_export_field.save).to be false
        expect(data_export_field.errors.messages).to have_key :exporter_type
      end  

      it "should fail to save if exporter_type is not in ALLOWED_TYPES" do
        random_type = "lol"
        expect(DataExportField::ALLOWED_TYPES).not_to include random_type
        data_export_field = build(:data_export_field, decision_aid_id: decision_aid.id,
                                                      exporter_type: random_type,
                                                      exporter_id: question.id,
                                                      data_target_type: "redcap",
                                                      redcap_field_name: "test_redcap_field")
        expect(data_export_field.save).to be false
        expect(data_export_field.errors.messages).to have_key :exporter_type
      end

      it "should fail to save if exporter_id is missing" do
        data_export_field = build(:data_export_field, decision_aid_id: decision_aid.id,
                                                      exporter_type: question.class.to_s,
                                                      data_target_type: "redcap",
                                                      redcap_field_name: "test_redcap_field")
        expect(data_export_field.save).to be false
        expect(data_export_field.errors.messages).to have_key :exporter_id
      end  

      it "should fail to save if data_target_type is missing" do
        data_export_field = build(:data_export_field, decision_aid_id: decision_aid.id,
                                                      exporter_id: question.id,
                                                      exporter_type: question.class.to_s,
                                                      redcap_field_name: "test_redcap_field")
        expect(data_export_field.save).to be false
        expect(data_export_field.errors.messages).to have_key :data_target_type
      end
    end

    describe "validate_per_data_target" do
      it "should fail to save if data_target_type is redcap and redcap_field_name is unset" do
        data_export_field = build(:data_export_field, decision_aid_id: decision_aid.id,
                                                      exporter_id: question.id,
                                                      exporter_type: question.class.to_s,
                                                      data_target_type: "redcap")
        expect(data_export_field.save).to be false
        expect(data_export_field.errors.messages).to have_key :redcap_field_name
      end
    end
  end

  describe "methods" do

    let (:question1) { create(:demo_text_question, decision_aid: decision_aid) }
    let (:property) { create(:property, decision_aid: decision_aid) }
    let (:summary_page) { create(:summary_page, decision_aid: decision_aid) }
    let (:decision_aid_user) { create(:decision_aid_user, decision_aid_id: decision_aid.id) }

    before do
      def1 = create(:data_export_field, decision_aid_id: decision_aid.id,
                                        exporter_id: question1.id,
                                        exporter_type: question1.class.to_s,
                                        data_target_type: "redcap",
                                        redcap_field_name: "test_redcap_field_1")

      def2 = create(:data_export_field, decision_aid_id: decision_aid.id,
                                        exporter_id: property.id,
                                        exporter_type: property.class.to_s,
                                        data_target_type: "redcap",
                                        redcap_field_name: "test_redcap_field_2")

      def3 = create(:data_export_field, decision_aid_id: decision_aid.id,
                                        exporter_id: summary_page.id,
                                        exporter_type: summary_page.class.to_s,
                                        data_target_type: "redcap",
                                        redcap_field_name: "test_redcap_field_3")

      def4 = create(:data_export_field, decision_aid_id: decision_aid.id,
                                        exporter_id: decision_aid_user.id,
                                        exporter_type: "Other",
                                        data_target_type: "redcap",
                                        redcap_field_name: "test_redcap_field_4")
    end

    describe "list_scope" do
      it "should add backend_identifier field to returned list" do

        fields = decision_aid.reload.data_export_fields.list_scope

        expect(fields.length).to be > 0

        fields.each do |field|
          expect(field).to respond_to :backend_identifier
          if field.exporter_type == "Question"
            expect(field.backend_identifier).to include "Question"
          elsif field.exporter_type == "Property"
            expect(field.backend_identifier).to include "Property"
          elsif field.exporter_type == "SummaryPage"
            expect(field.backend_identifier).to include "Summary page"
          elsif field.exporter_type == "Other"
            expect(field.backend_identifier).to include "N/A"
          else
            # fallback in case something bad happened
            expect(true).to be false
          end
        end
      end
    end

    describe "grouped_by_data_target" do
      it "should have a 'redcap' key in the grouped result" do
        target_ids = decision_aid.reload.data_export_fields.pluck(:id)
        grouped_targets = DataExportField.grouped_by_data_target(target_ids)
        expect(grouped_targets).to have_key "redcap"
      end
    end
  end
end
