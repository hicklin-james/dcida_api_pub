require "rails_helper"

RSpec.describe Api::DecisionAidUserResponsesController, :type => :controller do
  let (:decision_aid) { create(:full_decision_aid, slug: "test_decision_aid") }
  let (:decision_aid_user) { create(:decision_aid_user, decision_aid_id: decision_aid.id) }

  before do
    DecisionAidUserSession.create_or_update_user_session(decision_aid_user.id)
    request.headers.merge!("DECISION-AID-USER-ID" => decision_aid_user.id)
  end

  describe "index" do
    def generate_user_responses(da, dau)
      responses = []
      da.questions.each do |q|
        if q.question_response_type == "radio"
          responses.push create(:decision_aid_user_response, decision_aid_user_id: dau.id, question_id: q.id, question_response_id: q.question_responses.first.id)
        else
          responses.push create(:decision_aid_user_text_response, decision_aid_user_id: dau.id, question_id: q.id)
        end
      end
      responses
    end

    before do
      generate_user_responses(decision_aid, decision_aid_user)
    end

    it "should return demographic questions when params have question_type 'demographic'" do
      get :index, params: {decision_aid_user_id: decision_aid_user.id, question_type: "demographic"}
      responses = JSON.parse(response.body)["decision_aid_user_responses"]
      expect(responses.length).to be > 0
      responses.each do |r|
        expect(Question.find(r["question_id"]).question_type).to eq("demographic")
      end
    end

    it "should return quiz questions when params have question_type 'quiz'" do
      get :index, params: {decision_aid_user_id: decision_aid_user.id, question_type: "quiz"}
      responses = JSON.parse(response.body)["decision_aid_user_responses"]
      expect(responses.length).to be > 0
      responses.each do |r|
        expect(Question.find(r["question_id"]).question_type).to eq("quiz")
      end
    end

    it "should only return responses scoped to the decision aid user" do
      dau2 = create(:decision_aid_user, decision_aid_id: decision_aid.id)
      dau2_responses = generate_user_responses(decision_aid, dau2)
      get :index, params: {decision_aid_user_id: decision_aid_user.id, question_type: "demographic"}
      responses = JSON.parse(response.body)["decision_aid_user_responses"]
      expect(responses.length).to be > 0
      expect(dau2_responses.length).to be > 0
      dau2_responses.each do |r|
        expect(responses.map{|r| r["id"]}).not_to include(r.id)
      end
    end
  end

  describe "create_and_update_bulk" do
    def demographic_response_attributes(da, dau)
      response_attributes = []
       da.demographic_questions.each do |q|
        if q.question_response_type == "radio"
         response_attributes.push FactoryGirl.attributes_for(:decision_aid_user_response, decision_aid_user_id: dau.id, question_id: q.id, question_response_id: q.question_responses.first.id)
        else
          response_attributes.push FactoryGirl.attributes_for(:decision_aid_user_text_response, decision_aid_user_id: dau.id, question_id: q.id)
        end
      end
      response_attributes
    end

    def demographic_responses(da, dau)
      responses = []
       da.demographic_questions.each do |q|
        if q.question_response_type == "radio"
         responses.push create(:decision_aid_user_response, decision_aid_user_id: dau.id, question_id: q.id, question_response_id: q.question_responses.first.id)
        else
          responses.push create(:decision_aid_user_text_response, decision_aid_user_id: dau.id, question_id: q.id)
        end
      end
      responses
    end

    it "should return an error if there are no user responses in the request" do
      post :create_and_update_bulk, params: {decision_aid_user_id: decision_aid_user.id}
      expect(response.status).to eq(400)
      body = JSON.parse(response.body)
      expect(body.has_key?("errors")).to eq(true)
      expect(body["errors"].has_key?("decision_aid_user_responses")).to eq(true)
      expect(body["errors"]["decision_aid_user_responses"]).to include({"Exceptions::MissingParams" => 'ParamMissing'})
    end

    it "should create new user responses if params don't have ids present" do
      response_atts = demographic_response_attributes(decision_aid, decision_aid_user)
      expect{post(:create_and_update_bulk, params: {decision_aid_user_id: decision_aid_user.id, decision_aid_user_responses: response_atts})}
            .to change{DecisionAidUserResponse.count}.by(response_atts.length)
    end

    it "should update user responses if params have ids present" do
      drs = demographic_responses(decision_aid, decision_aid_user)
      expect{post(:create_and_update_bulk, params: {decision_aid_user_id: decision_aid_user.id, decision_aid_user_responses: drs.as_json})}
            .not_to change{DecisionAidUserResponse.count}
      expect(response.status).to eq(200)
    end

    it "should create new ones and update existing ones in the same request" do
      response_attributes = demographic_response_attributes(decision_aid, decision_aid_user)
      n = 0
      params = []
      while n < response_attributes.length / 2
        r = create(:decision_aid_user_response, response_attributes[n])
        params.push r.as_json
        n += 1
      end
      new_count = 0
      while n < response_attributes.length
        params.push response_attributes[n]
        n += 1
        new_count += 1
      end
      expect{post(:create_and_update_bulk, params: {decision_aid_user_id: decision_aid_user.id, decision_aid_user_responses: params})}
            .to change{DecisionAidUserResponse.count}.by(new_count)
      body = JSON.parse(response.body)
      expect(body.has_key?("decision_aid_user_responses")).to be true
      expect(body["decision_aid_user_responses"].kind_of?(Array)).to be true
      expect(body["decision_aid_user_responses"].length).to eq(params.length)
    end

    it "should raise an error if an invalid id is passed in the params" do
      drs = demographic_responses(decision_aid, decision_aid_user)
      drs.first.id = 0
      post(:create_and_update_bulk, params: {decision_aid_user_id: decision_aid_user.id, decision_aid_user_responses: drs.as_json})
      expect(response.status).to eq(400)
      body = JSON.parse(response.body)
      #expect(body["errors"].has_key?("decision_aid_user_responses")).to eq(true)
      expect(body["errors"].kind_of?(Array)).to be true
      expect(body["errors"]).to include('InvalidId')
    end

    it "should raise an error if there are some required params missing" do
      response_atts = demographic_response_attributes(decision_aid, decision_aid_user)
      response_atts.first[:question_id] = nil
      post(:create_and_update_bulk, params: {decision_aid_user_id: decision_aid_user.id, decision_aid_user_responses: response_atts})
      body = JSON.parse(response.body)
      #expect(body["errors"].has_key?("decision_aid_user_responses")).to eq(true)
      #expect(body["errors"]["decision_aid_user_responses"].map{|v| v.keys}.flatten).to include("ActiveRecord::RecordInvalid")
      expect(body["errors"].kind_of?(Array)).to be true
      expect(body["errors"]).to include("Validation failed: Question must exist")
    end
  end

end