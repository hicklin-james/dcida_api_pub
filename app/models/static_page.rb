# == Schema Information
#
# Table name: static_pages
#
#  id                  :integer          not null, primary key
#  page_text           :text
#  page_text_published :text
#  page_title          :text
#  static_page_order   :integer          not null
#  decision_aid_id     :integer
#  page_slug           :text
#  created_by_user_id  :integer
#  updated_by_user_id  :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class StaticPage < ApplicationRecord
  include Shared::UserStamps
  include Shared::HasAttachedItems
  include Shared::Orderable
  include Shared::CrossCloneable
  include Shared::Injectable

  belongs_to :decision_aid

  HAS_ATTACHED_ITEMS_ATTRIBUTES = [:page_text].freeze
  attributes_with_attached_items StaticPage::HAS_ATTACHED_ITEMS_ATTRIBUTES

  INJECTABLE_ATTRIBUTES = [:page_text_published].freeze
  injectable_attributes StaticPage::INJECTABLE_ATTRIBUTES

  scope :ordered, ->{ order(static_page_order: :asc) }

  counter_culture :decision_aid

  validates :decision_aid_id, :page_text, :static_page_order, :page_title, :page_slug, presence: true
  validates :page_slug, uniqueness: {scope: :decision_aid_id, message: "must be unique to decision aid"}

  acts_as_orderable :static_page_order, :order_scope
  attr_writer :update_order_after_destroy

  private

  def update_order_after_destroy
    true
  end

  def order_scope
    StaticPage.where(decision_aid_id: decision_aid_id).order(static_page_order: :asc)
  end
end
