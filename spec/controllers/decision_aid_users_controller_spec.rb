require "rails_helper"

RSpec.describe Api::DecisionAidUsersController, :type => :controller do
  let (:decision_aid) { create(:full_decision_aid, slug: "test_decision_aid") }
  let (:decision_aid_user) { create(:decision_aid_user, decision_aid_id: decision_aid.id) }

  before do
    DecisionAidUserSession.create_or_update_user_session(decision_aid_user.id)
    request.headers.merge!("DECISION-AID-USER-ID" => decision_aid_user.id)
  end

  describe "update" do
    it "should return an error if the user in the header does not match the user in the params" do
      dau2 = create(:decision_aid_user, decision_aid_id: decision_aid.id)
      post :update, params: {id: dau2.id}
      expect(response.status).to eq(401)
    end

    it "should update the user if the user in the params matches the current user" do
      option = decision_aid.options.first
      update_params = {selected_option_id: option.id}
      post :update, params: {id: decision_aid_user.id, decision_aid_user: update_params}
      expect(response.status).to eq(200)
      expect(decision_aid_user.reload.selected_option_id).to eq(option.id) 
    end
  end

end