# == Schema Information
#
# Table name: decision_aid_user_query_parameters
#
#  id                              :integer          not null, primary key
#  param_value                     :string
#  decision_aid_query_parameter_id :integer
#  decision_aid_user_id            :integer
#

class DecisionAidUserQueryParameter < ApplicationRecord
  belongs_to :decision_aid_query_parameter
  belongs_to :decision_aid_user

  validates :param_value, presence: true
  validates :param_value, uniqueness: {scope: :decision_aid_query_parameter}, :if => Proc.new { |qp| qp.decision_aid_query_parameter.is_primary}
end
