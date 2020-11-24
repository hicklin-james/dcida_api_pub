# == Schema Information
#
# Table name: animated_icon_array_graphics
#
#  id               :integer          not null, primary key
#  indicators_above :boolean          default(FALSE)
#  default_stage    :integer          default(0)
#

class AnimatedIconArrayGraphicSerializer < GraphicSerializer
  attributes :item_id,
    :id,
    :indicators_above,
    :default_stage,
    :animated_icon_array_graphic_stages

  def item_id
    object.acting_as.id
  end

  def animated_icon_array_graphic_stages
    stages = object.animated_icon_array_graphic_stages.ordered
    stages.map do |stage| 
      s = AnimatedIconArrayGraphicStageSerializer.new(stage)
      adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
      adapter.as_json
    end
  end
end
