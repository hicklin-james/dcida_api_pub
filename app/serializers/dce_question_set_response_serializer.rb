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

class DceQuestionSetResponseSerializer < ActiveModel::Serializer

  attributes :id, 
    :question_set, 
    :response_value, 
    :decision_aid_id, 
    :property_level_hash,
    :is_opt_out,
    :block_number

end
