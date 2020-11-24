# == Schema Information
#
# Table name: properties
#
#  id                        :integer          not null, primary key
#  title                     :string
#  selection_about           :text
#  long_about                :text
#  decision_aid_id           :integer          not null
#  created_by_user_id        :integer
#  updated_by_user_id        :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  selection_about_published :text
#  long_about_published      :text
#

class PropertyPreviewSerializer < ActiveModel::Serializer

  attributes :id,
    :title,
    :selection_about,
    :long_about,
    :decision_aid_id,
    :property_levels

  def property_levels
    pls = object.send :property_levels
    pls.map do |pl| 
      s = PropertyLevelPreviewSerializer.new(pl)
      adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
      adapter.as_json
    end
  end

end
