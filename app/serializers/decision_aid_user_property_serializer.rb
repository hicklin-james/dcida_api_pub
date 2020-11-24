# == Schema Information
#
# Table name: decision_aid_user_properties
#
#  id                    :integer          not null, primary key
#  property_id           :integer          not null
#  decision_aid_user_id  :integer          not null
#  weight                :integer          default(50)
#  order                 :integer          not null
#  color                 :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  traditional_value     :float
#  traditional_option_id :integer
#

class DecisionAidUserPropertySerializer < ActiveModel::Serializer

  attributes :id,
    :property_id,
    :decision_aid_user_id,
    :weight,
    :property_title,
    :order,
    :color,
    :traditional_value,
    :traditional_option_id

  def property_title
    if object.property.short_label then object.property.short_label else object.property.title end
  end

end
