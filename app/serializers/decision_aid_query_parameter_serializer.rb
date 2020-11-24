# == Schema Information
#
# Table name: decision_aid_query_parameters
#
#  id              :integer          not null, primary key
#  input_name      :string
#  output_name     :string
#  is_primary      :boolean
#  decision_aid_id :integer
#

class DecisionAidQueryParameterSerializer < ActiveModel::Serializer

  attributes :input_name,
    :output_name,
    :is_primary,
    :id

end
