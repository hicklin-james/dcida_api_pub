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

class DecisionAidQueryParameter < ApplicationRecord
  belongs_to :decision_aid
  has_many :decision_aid_user_query_parameters, dependent: :destroy

  validates :input_name, :output_name, presence: true
end
