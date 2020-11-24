# == Schema Information
#
# Table name: question_responses
#
#  id                          :integer          not null, primary key
#  question_id                 :integer          not null
#  decision_aid_id             :integer          not null
#  question_response_value     :string
#  is_correct_value            :boolean
#  question_response_order     :integer          not null
#  created_by_user_id          :integer
#  updated_by_user_id          :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  numeric_value               :float
#  redcap_response_value       :string
#  popup_information           :text
#  popup_information_published :text
#  include_popup_information   :boolean          default(FALSE)
#  skip_logic_target_count     :integer          default(0), not null
#

require "rails_helper"

RSpec.describe QuestionResponse, :type => :model do
  let (:decision_aid) { create(:basic_decision_aid) }
  let (:question) { create(:demo_radio_question, decision_aid_id: decision_aid.id) }

  describe "validations" do
    it "should fail to save if decision_aid_id is missing" do
      qr = build(:question_response)
      expect(qr.save).to be false
      expect(qr.errors.messages).to have_key :decision_aid_id
    end

    it "should fail to save if question_id is missing" do
      qr = build(:question_response)
      expect(qr.save).to be false
      expect(qr.errors.messages).to have_key :question
    end

    it "should save if all required attributes are there" do
      qr = build(:question_response, question_id: question.id, decision_aid_id: decision_aid.id, question_response_order: question.question_responses.length+1)
      expect(qr.save).to be true
    end
  end
end
