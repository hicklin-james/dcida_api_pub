# == Schema Information
#
# Table name: decision_aid_user_sub_decision_choices
#
#  id                   :integer          not null, primary key
#  decision_aid_user_id :integer
#  sub_decision_id      :integer
#  option_id            :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class DecisionAidUserSubDecisionChoiceSerializer < ActiveModel::Serializer
  attributes :id,
    :option_id,
    :sub_decision_id,
    :decision_aid_user_id
end
