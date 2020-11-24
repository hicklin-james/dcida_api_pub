require "rails_helper"

RSpec.describe Api::DecisionAidUserDceQuestionSetResponsesController, :type => :controller do
  let (:dce_decision_aid) { create(:dce_decision_aid, slug: "dce_decision_aid")}
  let (:decision_aid_user) { create(:decision_aid_user, decision_aid_id: dce_decision_aid.id) }
  let (:dau2) { create(:decision_aid_user, decision_aid_id: dce_decision_aid.id) }

  before do
    DecisionAidUserSession.create_or_update_user_session(decision_aid_user.id)
    request.headers.merge!("DECISION-AID-USER-ID" => decision_aid_user.id)
  end

  before(:each, user1: true) do
    DecisionAidUserSession.create_or_update_user_session(decision_aid_user.id)
    request.headers.merge!("DECISION-AID-USER-ID" => decision_aid_user.id)
  end

  before(:each, user2: true) do
    DecisionAidUserSession.create_or_update_user_session(dau2.id)
    request.headers.merge!("DECISION-AID-USER-ID" => dau2.id)
  end


  describe "create" do
    it "should create a response", user1: true do
      params = FactoryGirl.attributes_for(:decision_aid_user_dce_question_set_response, 
        dce_question_set_response_id: dce_decision_aid.dce_question_set_responses.first.id, 
        question_set: dce_decision_aid.dce_question_set_responses.first.question_set
      )
      post :create, params: {decision_aid_user_id: decision_aid_user.id, decision_aid_user_dce_question_set_response: params}
      expect(response.status).to eq 200
    end
  end

  describe "update" do

    let (:r) { create(:decision_aid_user_dce_question_set_response, 
      decision_aid_user_id: decision_aid_user.id, 
      dce_question_set_response_id: dce_decision_aid.dce_question_set_responses.first.id, 
      question_set: dce_decision_aid.dce_question_set_responses.first.question_set
    )}
    
    it "should update an existing response if user is creator", user1: true do
      params = { dce_question_set_response_id: dce_decision_aid.dce_question_set_responses.second.id}
      put :update, params: {decision_aid_user_id: decision_aid_user.id, id: r.id, decision_aid_user_dce_question_set_response: params}
      expect(response.status).to eq 200
    end

    it "should return 403 if user is not creator", user2: true do
      params = { dce_question_set_response_id: dce_decision_aid.dce_question_set_responses.second.id}
      put :update, params: {decision_aid_user_id: decision_aid_user.id, id: r.id, decision_aid_user_dce_question_set_response: params}
      expect(response.status).to eq 403
    end
  end

  describe "find_by_question_set" do
    
    let (:r) { create(:decision_aid_user_dce_question_set_response, 
      decision_aid_user_id: decision_aid_user.id, 
      dce_question_set_response_id: dce_decision_aid.dce_question_set_responses.first.id, 
      question_set: dce_decision_aid.dce_question_set_responses.first.question_set
    )}

    it "should return a response", user1: true do
      get :find_by_question_set, params: {decision_aid_user_id: decision_aid_user.id, question_set: r.question_set}
      expect(response.status).to eq 200
      body = JSON.parse(response.body)
      expect(body).to have_key "decision_aid_user_dce_question_set_response"
      expect(body["decision_aid_user_dce_question_set_response"]["id"].to_i).to eq r.id 
    end

    it "should return nothing if there is no response with the question set", user1: true do
      get :find_by_question_set, params: {decision_aid_user_id: decision_aid_user.id, question_set: 100000}
      expect(response.status).to eq 200
      body = JSON.parse(response.body)
      expect(body).not_to have_key "decision_aid_user_dce_question_set_response"
    end
  end

end