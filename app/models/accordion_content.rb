# == Schema Information
#
# Table name: accordion_contents
#
#  id                 :integer          not null, primary key
#  accordion_id       :integer          not null
#  header             :string
#  content            :text
#  order              :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  content_published  :text
#  is_open_by_default :boolean
#  panel_color        :integer
#  decision_aid_id    :integer
#

class AccordionContent < ApplicationRecord
  include Shared::HasAttachedItems
  include Shared::CrossCloneable

  enum panel_color: {default: 0, primary: 1, info: 2, success: 3, warning: 4, danger: 5}

  belongs_to :accordion, inverse_of: :accordion_contents
  validates :accordion, :decision_aid_id, presence: true

  default_scope { order(order: :asc) }

  HAS_ATTACHED_ITEMS_ATTRIBUTES = [:content].freeze

  attributes_with_attached_items AccordionContent::HAS_ATTACHED_ITEMS_ATTRIBUTES

  def self.destroy_panels(accordion_id, panel_ids)
    AccordionContent.where(id: panel_ids, accordion_id: accordion_id).destroy_all
  end
end
