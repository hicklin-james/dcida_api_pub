# == Schema Information
#
# Table name: properties
#
#  id                              :integer          not null, primary key
#  title                           :string
#  selection_about                 :text
#  long_about                      :text
#  decision_aid_id                 :integer          not null
#  created_by_user_id              :integer
#  updated_by_user_id              :integer
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  selection_about_published       :text
#  long_about_published            :text
#  property_order                  :integer
#  property_levels_count           :integer          default(0), not null
#  short_label                     :string
#  is_property_weighable           :boolean          default(TRUE)
#  are_option_properties_weighable :boolean          default(TRUE)
#  property_group_title            :string
#  backend_identifier              :string
#

class Property < ApplicationRecord
  include Shared::UserStamps
  include Shared::HasAttachedItems
  include Shared::Orderable
  include Shared::Injectable
  include Shared::CrossCloneable

  validates :decision_aid_id, :title, :property_order, presence: true
  validate :level_uniqueness_without_destroyed_attributes
  validate :level_count_in_best_worst

  belongs_to :decision_aid
  counter_culture :decision_aid
  has_many :option_properties, dependent: :destroy
  has_many :property_levels, -> { ordered }, dependent: :destroy, inverse_of: :property

  accepts_nested_attributes_for :property_levels, allow_destroy: true

  has_many :decision_aid_user_properties, dependent: :destroy
  has_many :decision_aid_user_option_properties, dependent: :destroy

  scope :ordered, ->{ order(property_order: :asc) }

  HAS_ATTACHED_ITEMS_ATTRIBUTES = [:selection_about, :long_about].freeze
  attributes_with_attached_items Property::HAS_ATTACHED_ITEMS_ATTRIBUTES

  acts_as_orderable :property_order, :order_scope
  attr_writer :update_order_after_destroy

  INJECTABLE_ATTRIBUTES = [:selection_about_published, :long_about_published].freeze
  injectable_attributes Property::INJECTABLE_ATTRIBUTES

  def clone_property(da)
    property_dup = self.dup
    property_dup.initialize_order(da.properties_count)

    begin
      ActiveRecord::Base.transaction do
        property_dup.save!
        property_dup.change_order(self.property_order + 1)
        clone_property_levels(property_dup)
      end
      {property: property_dup.reload}
    rescue => error
      {errors: [{"#{error.class}" => error.message}]}
    end

  end

  def self.get_remote_data_targets(property_ids)
    DataExportField.where(exporter_id: property_ids, exporter_type: "Property")
  end

  private

  def update_order_after_destroy
    true
  end

  def order_scope
    Property.where(decision_aid_id: decision_aid_id).order(property_order: :asc)
  end

  def level_uniqueness_without_destroyed_attributes
    levels = property_levels.reject(&:marked_for_destruction?)
    if levels.length != levels.uniq {|l| l.level_id}.length
      errors.add(:property_levels, "must have unique level ids")
    end
  end

  def level_count_in_best_worst
    if self.decision_aid and self.decision_aid.decision_aid_type == "best_worst"
      levels = property_levels.reject(&:marked_for_destruction?)
      if levels.length > 1
        errors.add(:property_levels, "can only have one level in best-worst scaled decision aids")
      end
    end
  end

  def clone_property_levels(cloned_property)
    property_levels.each do |pl|
      pl_dup = pl.dup
      pl_dup.property_id = cloned_property.id
      pl_dup.save!
    end
  end

end
