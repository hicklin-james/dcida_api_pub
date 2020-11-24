# == Schema Information
#
# Table name: question_responses
#
#  id                          :integer          not null, primary key
#  question_id                 :integer          not null
#  decision_aid_id             :integer          not null
#  question_response_value     :string
#  is_correct_value            :boolean
#  question_response_order     :integer          not null
#  created_by_user_id          :integer
#  updated_by_user_id          :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  numeric_value               :float
#  redcap_response_value       :string
#  popup_information           :text
#  popup_information_published :text
#  include_popup_information   :boolean          default(FALSE)
#  skip_logic_target_count     :integer          default(0), not null
#

class QuestionResponse < ApplicationRecord
  include Shared::UserStamps
  include Shared::HasAttachedItems
  include Shared::Injectable
  include Shared::CrossCloneable

  belongs_to :question, inverse_of: :question_responses
  validates :question, presence: true
  belongs_to :decision_aid
  validates :decision_aid_id, presence: true
  counter_culture :decision_aid
  has_many :decision_aid_user_responses, dependent: :destroy
  has_many :skip_logic_targets, dependent: :destroy, inverse_of: :question_response

  accepts_nested_attributes_for :skip_logic_targets, allow_destroy: true

  default_scope { order(question_response_order: :asc) }

  HAS_ATTACHED_ITEMS_ATTRIBUTES = [:popup_information].freeze
  attributes_with_attached_items QuestionResponse::HAS_ATTACHED_ITEMS_ATTRIBUTES

  INJECTABLE_ATTRIBUTES = [:popup_information_published].freeze
  injectable_attributes QuestionResponse::INJECTABLE_ATTRIBUTES
  
end
