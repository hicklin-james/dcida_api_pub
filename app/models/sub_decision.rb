# == Schema Information
#
# Table name: sub_decisions
#
#  id                                  :integer          not null, primary key
#  decision_aid_id                     :integer
#  sub_decision_order                  :integer
#  required_option_ids                 :integer          default([]), is an Array
#  created_by_user_id                  :integer
#  updated_by_user_id                  :integer
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  options_information                 :text
#  options_information_published       :text
#  other_options_information           :text
#  other_options_information_published :text
#  my_choice_information               :text
#  my_choice_information_published     :text
#  option_question_text                :text
#

class SubDecision < ApplicationRecord
  include Shared::UserStamps
  include Shared::HasAttachedItems
  include Shared::Injectable
  include Shared::Orderable
  include Shared::CrossCloneable

  belongs_to :decision_aid
  has_many :options, dependent: :destroy

  has_many :decision_aid_user_sub_decision_choices, dependent: :destroy
  has_many :section_trackers, dependent: :destroy

  counter_culture :decision_aid

  validates :sub_decision_order, uniqueness: {scope: :decision_aid_id}

  HAS_ATTACHED_ITEMS_ATTRIBUTES = [:options_information, :other_options_information, :my_choice_information].freeze
  attributes_with_attached_items SubDecision::HAS_ATTACHED_ITEMS_ATTRIBUTES

  INJECTABLE_ATTRIBUTES = [:options_information_published, :other_options_information_published, :my_choice_information_published].freeze
  injectable_attributes SubDecision::INJECTABLE_ATTRIBUTES

  acts_as_orderable :sub_decision_order, :order_scope
  attr_writer :update_order_after_destroy

  before_create :init_order

  scope :ordered, ->{ order(sub_decision_order: :asc) }

  private

  def init_order
    initialize_order(SubDecision.where(decision_aid_id: decision_aid_id).count)
  end

  def update_order_after_destroy
    true
  end

  def order_scope
    SubDecision.where(decision_aid_id: decision_aid_id).order(sub_decision_order: :asc)
  end
end
