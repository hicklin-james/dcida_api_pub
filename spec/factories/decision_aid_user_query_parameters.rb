# == Schema Information
#
# Table name: decision_aid_user_query_parameters
#
#  id                              :integer          not null, primary key
#  param_value                     :string
#  decision_aid_query_parameter_id :integer
#  decision_aid_user_id            :integer
#

FactoryGirl.define do
  factory :decision_aid_user_query_parameter do
    param_value "123"
  end
end
