# == Schema Information
#
# Table name: dce_question_sets
#
#  id                     :integer          not null, primary key
#  decision_aid_id        :integer
#  question_title         :string
#  dce_question_set_order :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class DceQuestionSet < ApplicationRecord
  include Shared::CrossCloneable
  has_many :dce_question_set_responses, dependent: :destroy
  belongs_to :decision_aid

  scope :ordered, ->{ order(dce_question_set_order: :asc) }
end
