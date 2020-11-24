# == Schema Information
#
# Table name: graphic_data
#
#  id                                   :integer          not null, primary key
#  graphic_id                           :integer
#  value                                :string
#  label                                :string
#  color                                :string
#  graphic_data_order                   :integer
#  sub_value                            :string
#  value_type                           :integer
#  sub_value_type                       :integer
#  animated_icon_array_graphic_stage_id :integer
#

class GraphicDatumSerializer < ActiveModel::Serializer
  attributes :id,
    :value,
    :value_type,
    :label,
    :sub_value_type,
    :sub_value,
    :color
end
