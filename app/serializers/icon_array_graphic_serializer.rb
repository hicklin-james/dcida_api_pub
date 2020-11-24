# == Schema Information
#
# Table name: icon_array_graphics
#
#  id                  :integer          not null, primary key
#  selected_index      :string
#  selected_index_type :integer
#  num_per_row         :integer
#

class IconArrayGraphicSerializer < GraphicSerializer
  attributes :id,
    :selected_index,
    :selected_index_type,
    :num_per_row,
    :item_id,
    :graphic_data

  def item_id
    object.acting_as.id
  end

  def graphic_data
    #puts instance_options.inspect
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
