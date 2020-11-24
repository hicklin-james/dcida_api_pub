# == Schema Information
#
# Table name: option_properties
#
#  id                    :integer          not null, primary key
#  information           :text
#  short_label           :text
#  option_id             :integer          not null
#  property_id           :integer          not null
#  decision_aid_id       :integer          not null
#  created_by_user_id    :integer
#  updated_by_user_id    :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  information_published :text
#  ranking               :text
#  ranking_type          :integer
#  short_label_published :text
#  button_label          :string
#

class OptionPropertySerializer < ActiveModel::Serializer

  attributes :id,
    :information,
    :short_label,
    :option_id,
    :property_id,
    :decision_aid_id,
    :ranking,
    :ranking_type,
    :is_weighable,
    :button_label

  def ranking
    object.ranking
  end

  def is_weighable
    object.property.are_option_properties_weighable
  end

end
