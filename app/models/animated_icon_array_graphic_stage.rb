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

class AnimatedIconArrayGraphicStage < ApplicationRecord
  belongs_to :animated_icon_array_graphic
  has_many :graphic_data, inverse_of: :animated_icon_array_graphic_stage
  accepts_nested_attributes_for :graphic_data, allow_destroy: true

  scope :ordered, ->{ order(graphic_stage_order: :asc) }

end
