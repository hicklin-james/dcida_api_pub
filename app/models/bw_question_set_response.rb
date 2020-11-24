# == Schema Information
#
# Table name: bw_question_set_responses
#
#  id                 :integer          not null, primary key
#  question_set       :integer
#  property_level_ids :integer          is an Array
#  decision_aid_id    :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  block_number       :integer          default(1), not null
#

class BwQuestionSetResponse < ApplicationRecord
  include Shared::CrossCloneable

  validates :decision_aid_id, :property_level_ids, :question_set, :presence => true
  validates :question_set, uniqueness: {scope: [:decision_aid_id, :block_number]}

  has_many :decision_aid_user_bw_question_set_responses, dependent: :destroy

  counter_culture :decision_aid
  belongs_to :decision_aid

  default_scope { order(question_set: :asc) }

  # scope :property_levels, -> (object) {
  #   where(id: object.attributes["property_level_ids"])
  #     .joins("LEFT OUTER JOIN properties ON property_levels.property_id = properties.id")
  #     .select("property_levels.*, properties.title AS property_title")
  #   }

  def property_levels
    PropertyLevel.where(id: property_level_ids)
      .joins("LEFT OUTER JOIN properties ON property_levels.property_id = properties.id")
      .select("property_levels.*, properties.title AS property_title")
      .order("properties.property_order")
  end

end
