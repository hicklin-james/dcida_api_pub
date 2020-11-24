# == Schema Information
#
# Table name: graphic_object_references
#
#  id          :integer          not null, primary key
#  graphic_id  :integer
#  object_id   :integer
#  object_type :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class GraphicObjectReference < ApplicationRecord
  belongs_to :graphic
end
