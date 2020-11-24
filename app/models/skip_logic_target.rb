# == Schema Information
#
# Table name: skip_logic_targets
#
#  id                      :integer          not null, primary key
#  question_page_id        :integer
#  question_response_id    :integer
#  decision_aid_id         :integer
#  target_entity           :integer
#  skip_question_page_id   :integer
#  skip_page_url           :string
#  skip_logic_target_order :integer          not null
#  created_by_user_id      :integer
#  updated_by_user_id      :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class SkipLogicTarget < ApplicationRecord
  include Shared::UserStamps
  include Shared::CrossCloneable

  belongs_to :question_page, inverse_of: :skip_logic_targets, optional: true
  belongs_to :question_response, inverse_of: :skip_logic_targets, optional: true
  belongs_to :decision_aid

  has_many :skip_logic_conditions, dependent: :destroy, inverse_of: :skip_logic_target

  validates :decision_aid_id, :target_entity, :skip_logic_target_order, presence: true

  counter_culture :question_page, column_name: "skip_logic_target_count"
  counter_culture :question_response, column_name: "skip_logic_target_count"

  enum target_entity: {question_page: 1, end_of_questions: 2, external_page: 3, other_section: 4}

  accepts_nested_attributes_for :skip_logic_conditions, allow_destroy: true

  scope :ordered, ->{ order(skip_logic_target_order: :asc) }

  validate :validate_only_one_owner

  def evaluate_skip_logic_target(dau)
    self.skip_logic_conditions.ordered.each_with_index do |slc, ind|
      boolVal = slc.evaluate_condition(dau)

      return true if boolVal and ind == self.skip_logic_conditions.count-1

      case slc.logical_operator
      when "logical_and"
        return false if !boolVal
        next
      when "logical_or"
        return true if boolVal
        next
      end
    end

    return false
  end

  def validate_only_one_owner
    if !question_response and !question_page
      errors.add(:question, "must belong to question_page or question response.")
    end

    if question_response and question_page
      errors.add(:question, "must belong to only one of question_page or question response, not both.")
    end
  end

end
