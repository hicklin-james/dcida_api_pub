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

class GraphicDatum < ApplicationRecord
  belongs_to :graphic, inverse_of: :graphic_data, optional: true
  belongs_to :animated_icon_array_graphic_stage, inverse_of: :graphic_data, optional: true

  enum value_type: {decimal: 0, question_response: 1}
  enum sub_value_type: {dec: 0, qr: 1} # different names because rails doesnt like two enums with same values

  validates :value, :graphic_data_order, :value_type, presence: true
  validate :graphic_or_stage_set

  default_scope { order(graphic_data_order: :asc) }

  scope :ordered, ->{ order(graphic_data_order: :asc) }

  private

  def graphic_or_stage_set
    if !graphic && !animated_icon_array_graphic_stage
      errors.add(:graphic_or_stage, "graphic or animated_icon_array_graphic_stage must be set")
    end
  end

  # def init_order
  #   initialize_order(GraphicDatum.where(graphic_id: self.graphic_id).count)
  # end

  # def update_order_after_destroy
  #   true
  # end

  # def order_scope
  #   GraphicDatum.where(graphic_id: self.graphic_id).order(graphic_data_order: :asc)
  # end

end
