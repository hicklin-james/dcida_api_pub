# == Schema Information
#
# Table name: decision_aid_user_query_parameters
#
#  id                              :integer          not null, primary key
#  param_value                     :string
#  decision_aid_query_parameter_id :integer
#  decision_aid_user_id            :integer
#

require 'rails_helper'

RSpec.describe DecisionAidUserQueryParameter, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
