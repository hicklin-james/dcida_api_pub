# == Schema Information
#
# Table name: animated_icon_array_graphic_stages
#
#  id                             :integer          not null, primary key
#  animated_icon_array_graphic_id :integer
#  total_n                        :integer
#  general_label                  :string
#  seperate_values                :boolean          default(FALSE)
#  graphic_stage_order            :integer          not null
#

class AnimatedIconArrayGraphicStageSerializer < ActiveModel::Serializer
  attributes :animated_icon_array_graphic_id,
    :id,
    :total_n,
    :general_label,
    :seperate_values,
    :graphic_stage_order,
    :graphic_data

  def graphic_data
    object.graphic_data.ordered.map {|gd|
      s = GraphicDatumSerializer.new(gd)
      adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
      adapter.as_json
    }
  end
end
