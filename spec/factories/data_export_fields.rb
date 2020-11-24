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

FactoryGirl.define do
  factory :data_export_field do

    after(:build) do |data_export_field, evaluator|
      if data_export_field.decision_aid_id
        data_export_field.initialize_order(data_export_field.decision_aid.reload.data_export_fields_count)
      end
    end
  end
end
