# == Schema Information
#
# Table name: property_levels
#
#  id                    :integer          not null, primary key
#  information           :text
#  information_published :text
#  level_id              :integer
#  property_id           :integer          not null
#  created_by_user_id    :integer
#  updated_by_user_id    :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  decision_aid_id       :integer
#

class PropertyLevel < ApplicationRecord
  include Shared::HasAttachedItems
  include Shared::Injectable
  include Shared::UserStamps
  include Shared::CrossCloneable

  belongs_to :property, inverse_of: :property_levels
  belongs_to :decision_aid
  counter_culture :property

  validates :level_id, :property, :decision_aid_id, presence: true

  #default_scope { order(level_id: :asc) }

  scope :ordered, ->{ order(level_id: :asc) }

  has_many :decision_aid_user_best_property_levels, dependent: :destroy, foreign_key: "best_property_level_id", class_name: "DecisionAidUserBwQuestionSetResponse"
  has_many :decision_aid_user_worst_property_levels, dependent: :destroy, foreign_key: "worst_property_level_id",  class_name: "DecisionAidUserBwQuestionSetResponse"

  HAS_ATTACHED_ITEMS_ATTRIBUTES = [:information].freeze
  attributes_with_attached_items PropertyLevel::HAS_ATTACHED_ITEMS_ATTRIBUTES

  INJECTABLE_ATTRIBUTES = [:information_published].freeze
  injectable_attributes PropertyLevel::INJECTABLE_ATTRIBUTES

end
