# == Schema Information
#
# Table name: dce_question_set_responses
#
#  id                  :integer          not null, primary key
#  question_set        :integer
#  response_value      :integer
#  property_level_hash :json
#  decision_aid_id     :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  block_number        :integer          default(1), not null
#  is_opt_out          :boolean          default(FALSE)
#  dce_question_set_id :integer
#

class DceQuestionSetResponse < ApplicationRecord
  include Shared::CrossCloneable

  validates :question_set, :response_value, :decision_aid_id, :property_level_hash, presence: true
  validates :response_value, uniqueness: {scope: [:decision_aid_id, :question_set, :block_number]}

  counter_culture :decision_aid
  belongs_to :decision_aid
  belongs_to :dce_question_set, optional: true

  has_many :decision_aid_user_dce_question_set_responses, dependent: :destroy

  default_scope { order(question_set: :asc, response_value: :asc) }

end
