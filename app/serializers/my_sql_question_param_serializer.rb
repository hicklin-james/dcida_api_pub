# == Schema Information
#
# Table name: my_sql_question_params
#
#  id                          :integer          not null, primary key
#  param_source                :integer
#  param_type                  :string
#  value                       :string
#  my_sql_question_param_order :integer
#  question_id                 :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#

class MySqlQuestionParamSerializer < ActiveModel::Serializer

  attributes :id,
    :param_source,
    :param_type,
    :value,
    :question_id

end
