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

require 'rails_helper'

RSpec.describe DecisionAidQueryParameter, type: :model do

  let (:decision_aid) { create(:basic_decision_aid) }

  describe "validations" do
    it "should fail to save if input_name is missing" do
      qp = build(:decision_aid_query_parameter, decision_aid_id: decision_aid.id, input_name: nil)
      expect(qp.save).to be false
      expect(qp.errors.messages).to have_key :input_name
    end

    it "should fail to save if ouput_name is missing" do
      qp = build(:decision_aid_query_parameter, decision_aid_id: decision_aid.id, output_name: nil)
      expect(qp.save).to be false
      expect(qp.errors.messages).to have_key :output_name
    end

    it "should save if all required params exist" do
      qp = build(:decision_aid_query_parameter, decision_aid_id: decision_aid.id)
      expect(qp.save).to be true
    end
  end
end
