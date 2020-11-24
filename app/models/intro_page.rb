# == Schema Information
#
# Table name: intro_pages
#
#  id                    :integer          not null, primary key
#  description           :text
#  description_published :text
#  decision_aid_id       :integer
#  intro_page_order      :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  created_by_user_id    :integer
#  updated_by_user_id    :integer
#

class IntroPage < ApplicationRecord
  include Shared::UserStamps
  include Shared::HasAttachedItems
  include Shared::Orderable
  include Shared::Injectable
  include Shared::CrossCloneable

  HAS_ATTACHED_ITEMS_ATTRIBUTES = [:description].freeze
  attributes_with_attached_items IntroPage::HAS_ATTACHED_ITEMS_ATTRIBUTES

  INJECTABLE_ATTRIBUTES = [:description_published].freeze
  injectable_attributes IntroPage::INJECTABLE_ATTRIBUTES

  scope :ordered, ->{ order(intro_page_order: :asc) }

  counter_culture :decision_aid

  belongs_to :decision_aid

  has_many :basic_page_submissions, dependent: :destroy

  validates :decision_aid_id, :description, presence: true

  before_create :init_order

  acts_as_orderable :intro_page_order, :order_scope
  attr_writer :update_order_after_destroy

  private 

  def init_order
    initialize_order(IntroPage.where(decision_aid_id: decision_aid_id).count)
  end

  def update_order_after_destroy
    true
  end

  def order_scope
    IntroPage.where(decision_aid_id: decision_aid_id).order(intro_page_order: :asc)
  end

end
