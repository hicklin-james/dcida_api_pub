# == Schema Information
#
# Table name: horizontal_bar_chart_graphics
#
#  id                  :integer          not null, primary key
#  selected_index      :string
#  selected_index_type :integer
#  max_value           :string
#

class HorizontalBarChartGraphicSerializer < GraphicSerializer
  attributes :selected_index,
    :selected_index_type,
    :max_value,
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
