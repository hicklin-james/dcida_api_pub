# == Schema Information
#
# Table name: decision_aid_query_parameters
#
#  id              :integer          not null, primary key
#  input_name      :string
#  output_name     :string
#  is_primary      :boolean
#  decision_aid_id :integer
#

FactoryGirl.define do
  factory :decision_aid_query_parameter do
    input_name "pid"
    output_name "pid"
    is_primary true
  end
end
