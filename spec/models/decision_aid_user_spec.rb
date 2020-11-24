# == Schema Information
#
# Table name: decision_aid_users
#
#  id                                                 :integer          not null, primary key
#  decision_aid_id                                    :integer          not null
#  selected_option_id                                 :integer
#  created_at                                         :datetime         not null
#  updated_at                                         :datetime         not null
#  decision_aid_user_responses_count                  :integer          default(0), not null
#  decision_aid_user_properties_count                 :integer          default(0), not null
#  decision_aid_user_option_properties_count          :integer          default(0), not null
#  decision_aid_user_dce_question_set_responses_count :integer          default(0), not null
#  decision_aid_user_bw_question_set_responses_count  :integer          default(0), not null
#  decision_aid_user_sub_decision_choices_count       :integer          default(0), not null
#  about_me_complete                                  :boolean          default(FALSE)
#  quiz_complete                                      :boolean          default(FALSE)
#  randomized_block_number                            :integer
#  unique_id_name                                     :integer
#  estimated_end_time                                 :datetime
#  other_properties                                   :text
#  platform                                           :string
#

require "rails_helper"

RSpec.describe DecisionAidUser, :type => :model do
  let (:decision_aid) { create(:basic_decision_aid, slug: "test_decision_aid") }

  describe "validations" do
    it "fails to create a decision aid user when the decision aid is missing" do
      dau = build(:decision_aid_user)
      expect(dau.save).to be false
      expect(dau.errors.messages).to have_key :decision_aid_id
    end

    it "saves if all required attributes exist and validations pass" do
      dau = build(:decision_aid_user, decision_aid_id: decision_aid.id)
      expect(dau.save).to be true
    end
  end

  describe "methods" do
    describe "::find_or_create_decision_aid_user" do
      let (:decision_aid_user) { create(:decision_aid_user, decision_aid_id: decision_aid.id) }

      it "should return the decision aid user if it exists with the pid" do
        pid = 54321
        dau = create(:decision_aid_user, decision_aid_id: decision_aid.id)
        dauqp = create(:decision_aid_user_query_parameter, decision_aid_user_id: dau.id, decision_aid_query_parameter_id: decision_aid.decision_aid_query_parameters.first.id, param_value: pid.to_s)
        r = DecisionAidUser.find_or_create_decision_aid_user(decision_aid, decision_aid_user.id, {"pid" => pid.to_s}, "")
        expect(r).to have_key :new_user
        expect(r[:new_user]).to be false
        expect(r).to have_key :user
        expect(r[:user]).to eq dau
      end

      it "should return a new user if no user exists with the parameters" do
        r = DecisionAidUser.find_or_create_decision_aid_user(decision_aid, 0, nil, "")
        expect(r).to have_key :new_user
        expect(r[:new_user]).to be true
      end
    end

    describe "::pid" do
      let (:decision_aid_user) { create(:decision_aid_user, decision_aid_id: decision_aid.id) }

      it "should return the param value of the primary query parameter" do
        pid = "5432"
        create(:decision_aid_user_query_parameter, 
          param_value: pid, 
          decision_aid_query_parameter_id: decision_aid.decision_aid_query_parameters.where(is_primary: true).take.id,
          decision_aid_user_id: decision_aid_user.id)
        expect(decision_aid_user.pid).to eq(pid)
      end

      it "should return the param value of the primary query parameter even if there are other query parameters" do
        pid = "5432"
        create(:decision_aid_user_query_parameter, 
          param_value: pid, 
          decision_aid_query_parameter_id: decision_aid.decision_aid_query_parameters.where(is_primary: true).take.id,
          decision_aid_user_id: decision_aid_user.id)
        p1 = create(:decision_aid_query_parameter, 
          decision_aid_id: decision_aid.id,
          input_name: "trust",
          output_name: "me",
          is_primary: false)
        p2 = create(:decision_aid_query_parameter, 
          decision_aid_id: decision_aid.id,
          input_name: "take",
          output_name: "out",
          is_primary: false)
        create(:decision_aid_user_query_parameter, 
          param_value: "abc", 
          decision_aid_query_parameter_id: p1.id,
          decision_aid_user_id: decision_aid_user.id)
        create(:decision_aid_user_query_parameter, 
          param_value: "def", 
          decision_aid_query_parameter_id: p2.id,
          decision_aid_user_id: decision_aid_user.id)

        expect(decision_aid_user.reload.pid).to eq(pid)
      end

      it "should return nil if there is no user parameter" do
        expect(decision_aid_user.pid).to eq(nil)
      end
    end
  end

end
