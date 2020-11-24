# == Schema Information
#
# Table name: nav_links
#
#  id                 :integer          not null, primary key
#  link_href          :string
#  link_text          :string
#  link_location      :integer
#  nav_link_order     :integer          not null
#  decision_aid_id    :integer
#  created_by_user_id :integer
#  updated_by_user_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class NavLink < ApplicationRecord
  include Shared::UserStamps
  include Shared::HasAttachedItems
  include Shared::Orderable
  include Shared::CrossCloneable

  belongs_to :decision_aid

  scope :ordered, ->{ order(nav_link_order: :asc) }

  counter_culture :decision_aid

  validates :decision_aid_id, :link_href, :link_text, :nav_link_order, presence: true

  acts_as_orderable :nav_link_order, :order_scope
  attr_writer :update_order_after_destroy

  def update_order_after_destroy
    true
  end

  def order_scope
    NavLink.where(decision_aid_id: decision_aid_id).order(nav_link_order: :asc)
  end
end
