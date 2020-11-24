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

class DceQuestionSetSerializer < ActiveModel::Serializer
  
  attributes :id,
  	:question_title,
  	:dce_question_set_order
    
end

