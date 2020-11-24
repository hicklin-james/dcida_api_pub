# == Schema Information
#
# Table name: summary_panels
#
#  id                                 :integer          not null, primary key
#  panel_type                         :integer
#  panel_information                  :text
#  panel_information_published        :text
#  question_ids                       :integer          default([]), is an Array
#  summary_panel_order                :integer
#  decision_aid_id                    :integer
#  created_by_user_id                 :integer
#  updated_by_user_id                 :integer
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  option_lookup_json                 :json
#  lookup_headers_json                :json
#  summary_table_header_json          :json
#  injectable_decision_summary_string :string
#  summary_page_id                    :integer          not null
#

class SummaryPanel < ApplicationRecord
  include Shared::UserStamps
  include Shared::HasAttachedItems
  include Shared::Orderable
  include Shared::Injectable
  include Shared::CrossCloneable

  HAS_ATTACHED_ITEMS_ATTRIBUTES = [:panel_information].freeze
  attributes_with_attached_items SummaryPanel::HAS_ATTACHED_ITEMS_ATTRIBUTES

  INJECTABLE_ATTRIBUTES = [:panel_information_published, :injectable_decision_summary_string].freeze
  injectable_attributes SummaryPanel::INJECTABLE_ATTRIBUTES

  scope :primary, ->{ joins("JOIN summary_pages spa ON (spa.id = summary_panels.summary_page_id)").where("spa.is_primary = TRUE") }
  scope :ordered, ->{ order(summary_panel_order: :asc) }

  enum panel_type: { text: 0, question_responses: 1, decision_summary: 2 }

  belongs_to :decision_aid
  belongs_to :summary_page
  counter_culture :summary_page

  validates :decision_aid_id, :summary_page_id, :summary_panel_order, :panel_type, presence: true

  acts_as_orderable :summary_panel_order, :order_scope
  attr_writer :update_order_after_destroy

  private

  def update_order_after_destroy
    true
  end

  def order_scope
    SummaryPanel.where(decision_aid_id: decision_aid_id, summary_page_id: summary_page_id).order(summary_panel_order: :asc)
  end

end
