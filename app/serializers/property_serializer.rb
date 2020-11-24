# == Schema Information
#
# Table name: properties
#
#  id                              :integer          not null, primary key
#  title                           :string
#  selection_about                 :text
#  long_about                      :text
#  decision_aid_id                 :integer          not null
#  created_by_user_id              :integer
#  updated_by_user_id              :integer
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  selection_about_published       :text
#  long_about_published            :text
#  property_order                  :integer
#  property_levels_count           :integer          default(0), not null
#  short_label                     :string
#  is_property_weighable           :boolean          default(TRUE)
#  are_option_properties_weighable :boolean          default(TRUE)
#  property_group_title            :string
#  backend_identifier              :string
#

class PropertyLevelSerializer < ActiveModel::Serializer
  cache key: "property_level", expires_in: 3.hours

  attributes :id,
    :information,
    :level_id

end

class PropertySerializer < ActiveModel::Serializer

  cache key: "property", expires_in: 3.hours

  attributes :id,
    :title,
    :selection_about,
    :long_about,
    :decision_aid_id,
    :property_order,
    :is_dce,
    :short_label,
    :is_property_weighable,
    :are_option_properties_weighable,
    :property_group_title,
    :backend_identifier

  has_many :property_levels, serializer: PropertyLevelSerializer

  def is_dce
    object.decision_aid.decision_aid_type == 'dce'
  end

end
