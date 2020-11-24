class PropertyLevelPreviewSerializer < ActiveModel::Serializer

  attributes :id, 
    :level_id, 
    :property_id,
    :information_published,
    :property_title

  def property_title
    if object.respond_to?(:property_title)
      object.property_title
    else
      nil
    end
  end

end