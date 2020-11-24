# == Schema Information
#
# Table name: decision_aid_user_option_properties
#
#  id                   :integer          not null, primary key
#  option_property_id   :integer          not null
#  option_id            :integer          not null
#  property_id          :integer          not null
#  decision_aid_user_id :integer          not null
#  value                :float            not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class DecisionAidUserOptionPropertySerializer < ActiveModel::Serializer

  attributes :id,
    :option_id,
    :property_id,
    :option_property_id,
    :decision_aid_user_id,
    :value,
    :submitted

  def submitted
    true
  end

end
