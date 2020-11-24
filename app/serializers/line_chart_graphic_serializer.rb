# == Schema Information
#
# Table name: line_chart_graphics
#
#  id          :integer          not null, primary key
#  x_label     :string
#  y_label     :string
#  chart_title :string
#  min_value   :integer
#  max_value   :integer
#

class LineChartGraphicSerializer < GraphicSerializer
  attributes :chart_title,
    :min_value,
    :max_value,
    :x_label,
    :y_label,
    :item_id,
    :graphic_data,
    :id

  def item_id
    object.acting_as.id
  end

  def graphic_data
    parent_obj = instance_options[:parent_obj]
    if parent_obj
      parent_obj.graphic_data.map {|gd|
        s = GraphicDatumSerializer.new(gd)
        adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
        adapter.as_json
      }
    else
      []
    end
  end
end
