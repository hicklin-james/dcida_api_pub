class DceQuestionSetResponsePreviewSerializer < ActiveModel::Serializer

  attributes :id, 
    :question_set, 
    :response_value, 
    :decision_aid_id, 
    :property_level_hash,
    :is_opt_out,
    :block_number

end