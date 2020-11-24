require "rails_helper"

RSpec.describe Api::DecisionAidHomeController, :type => :controller do

  let (:decision_aid) { create(:full_decision_aid, slug: "test_decision_aid") }
  let (:decision_aid_user) { create(:decision_aid_user, decision_aid_id: decision_aid.id) }

  before do
    DecisionAidUserSession.create_or_update_user_session(decision_aid_user.id)
    request.headers.merge!("DECISION-AID-USER-ID" => decision_aid_user.id)
  end

  describe "session" do
    it "should return 200 when there is a valid session" do
      get :intro, params: {slug: "test_decision_aid"}
      expect(response.status).to eq(200)
    end

    it "should return 404 if the slug is a non-existent decision aid" do
      get :intro, params: {slug: "1234"}
      expect(response.status).to eq(404)
    end

    it "should return 401 if the session doesn't exist" do
      du = create(:decision_aid_user, decision_aid_id: decision_aid.id)
      request.headers["DECISION-AID-USER-ID"] = du.id
      get :intro, params: {slug: "test_decision_aid"}
      expect(response.status).to eq(401)
    end

    it "should return 200 if the session is valid within the day" do
      daus = DecisionAidUserSession.where(decision_aid_user_id: decision_aid_user.id).first
      daus.last_access = 1.hour.ago
      daus.save
      get :intro, params: {slug: "test_decision_aid"}
      expect(response.status).to eq(200)
    end

    it "should return 401 if the session is no longer valid" do
      daus = DecisionAidUserSession.where(decision_aid_user_id: decision_aid_user.id).first
      daus.last_access = 2.days.ago
      daus.save
      get :intro, params: {slug: "test_decision_aid"}
      expect(response.status).to eq(401)
    end

    it "should create the decision aid user on get_decision_aid_user if the user id is missing from the request headers" do
      request.headers["DECISION-AID-USER-ID"] = nil
      expect{get(:get_decision_aid_user, params: {slug: "test_decision_aid"})}.to change{DecisionAidUser.count}.by(1)
      expect(JSON.parse(response.body)["meta"]["is_new_user"]).to be true
    end

    it "should create the decision aid user session on get_decision_aid_user if the user id is missing from the request headers" do
      request.headers["DECISION-AID-USER-ID"] = nil
      expect{get(:get_decision_aid_user, params: {slug: "test_decision_aid"})}.to change{DecisionAidUserSession.count}.by(1)
    end

    it "shouldn't create a new decision aid user if the decision aid user is on the request headers" do
      expect{get(:get_decision_aid_user, params: {slug: "test_decision_aid"})}.not_to change{DecisionAidUser.count}
      expect(JSON.parse(response.body)["meta"]["is_new_user"]).to be false
    end

    it "shouldn't create a new session if the decision aid user is on the request headers" do
      expect{get(:get_decision_aid_user, params: {slug: "test_decision_aid"})}.not_to change{DecisionAidUserSession.count}
    end

    it "shouldn't create a new decision aid user if the pid passed already exists for the same decision aid" do
      dauqp = create(:decision_aid_user_query_parameter, decision_aid_user_id: decision_aid_user.id, decision_aid_query_parameter_id: decision_aid.decision_aid_query_parameters.first.id, param_value: "1234567890")
      daus = DecisionAidUserSession.where(decision_aid_user_id: decision_aid_user.id).first
      #decision_aid_user.pid = "1234567890"
      #decision_aid_user.save
      expect{get(:get_decision_aid_user, params: {slug: "test_decision_aid", query_params: {"pid" => "1234567890"}.to_json})}.to change {DecisionAidUserSession.count}.by(0)
                                                                                            .and change {DecisionAidUser.count}.by(0)                                                                                   
      expect(JSON.parse(response.body)["meta"]["is_new_user"]).to be false
    end

    it "should create a new decision aid user if the pid passed doesn't exist for the decision aid" do
      dauqp = create(:decision_aid_user_query_parameter, decision_aid_user_id: decision_aid_user.id, decision_aid_query_parameter_id: decision_aid.decision_aid_query_parameters.first.id, param_value: "1234567890")
      da2 = create(:full_decision_aid, slug: "test_decision_aid_two")
      request.headers["DECISION-AID-USER-ID"] = nil
      #decision_aid_user.pid = "1234567890"
      #decision_aid_user.save
      expect{get(:get_decision_aid_user, params: {slug: "test_decision_aid_two", query_params: {"pid" => "1234567890"}.to_json})}.to change {DecisionAidUserSession.count}.by(1)
                                                                                            .and change {DecisionAidUser.count}.by(1)                                                                                
      expect(JSON.parse(response.body)["meta"]["is_new_user"]).to be true
    end

    it "should update the existing session if one exists for the decision aid and pid" do
      dauqp = create(:decision_aid_user_query_parameter, decision_aid_user_id: decision_aid_user.id, decision_aid_query_parameter_id: decision_aid.decision_aid_query_parameters.first.id, param_value: "1234567890")
      daus = DecisionAidUserSession.where(decision_aid_user_id: decision_aid_user.id).first
      two_days_ago = 2.days.ago
      daus.last_access = two_days_ago
      daus.save
      get(:get_decision_aid_user, params: {slug: "test_decision_aid", pid: "1234567890"})
      expect(daus.reload.last_access).not_to eq(two_days_ago)  
    end
  end

  describe "intro" do

    it "should only be the intro available" do
      get :intro, params: {slug: "test_decision_aid"}
      body = JSON.parse(response.body)
      pages = body["meta"]["pages"]
      expect(pages["intro"]["available"]).to be true
      expect(pages["about"]["available"]).to be false
      expect(pages["properties"]["available"]).to be false
      expect(pages["results_#{decision_aid.sub_decisions.first.sub_decision_order}"]["available"]).to be false
      expect(pages["quiz"]["available"]).to be false
      expect(pages["summary"]["available"]).to be false
    end

    it "should be the correct decision aid user" do
      get :intro, params: {slug: "test_decision_aid"}
      body = JSON.parse(response.body)
      expect(body["meta"]["decision_aid_user"]["id"]).to eq(decision_aid_user.id)
    end

    it "should not be a new user" do
      get :intro, params: {slug: "test_decision_aid"}
      body = JSON.parse(response.body)
      expect(body["meta"]["is_new_user"]).to be false
    end
  end

  describe "about" do

    before do 
      decision_aid.intro_pages.each do |ip|
        create(:basic_page_submission, decision_aid_user_id: decision_aid_user.id, intro_page_id: ip.id)
      end
    end

    it "should only be the intro and about page available" do
      get :about, params: {slug: "test_decision_aid"}
      body = JSON.parse(response.body)
      pages = body["meta"]["pages"]
      expect(pages["intro"]["available"]).to be true
      expect(pages["about"]["available"]).to be true
      expect(pages["properties"]["available"]).to be false
      expect(pages["results_#{decision_aid.sub_decisions.first.sub_decision_order}"]["available"]).to be false
      expect(pages["quiz"]["available"]).to be false
      expect(pages["summary"]["available"]).to be false
    end

    it "should be the correct decision aid user" do
      get :about, params: {slug: "test_decision_aid"}
      body = JSON.parse(response.body)
      expect(body["meta"]["decision_aid_user"]["id"]).to eq(decision_aid_user.id)
    end

    it "should have question_page under decision aid" do
      q1 = create(:demo_grid_question, decision_aid_id: decision_aid.id)
      get :about, params: {slug: "test_decision_aid"}
      body = JSON.parse(response.body)
      expect(body).to have_key "decision_aid"
      expect(body["decision_aid"]).to have_key "question_page"
    end

    it "should not be a new user" do
      get :about, params: {slug: "test_decision_aid"}
      body = JSON.parse(response.body)
      expect(body["meta"]["is_new_user"]).to be false
    end
  end


  # TODO:
  # TAKEN OUT OF DECISION AIDS
  # Remove or reimplement?

=begin  
  describe "options" do

    before do
      decision_aid.demographic_questions.ordered.each do |q|
        if q.question_response_type == "radio"
          create(:decision_aid_user_response, decision_aid_user_id: decision_aid_user.id, question_id: q.id, question_response_id: q.question_responses.first.id)
        else
          create(:decision_aid_user_text_response, decision_aid_user_id: decision_aid_user.id, question_id: q.id)
        end
      end
    end

    it "should only be the options and options page available" do
      get :options, slug: "test_decision_aid"
      body = JSON.parse(response.body)
      pages = body["meta"]["pages"]
      expect(pages["intro"]["available"]).to be true
      expect(pages["about"]["available"]).to be true
      expect(pages["options_#{decision_aid.sub_decisions.first.sub_decision_order}"]["available"]).to be true
      expect(pages["properties"]["available"]).to be false
      expect(pages["results_#{decision_aid.sub_decisions.first.sub_decision_order}"]["available"]).to be false
      expect(pages["quiz"]["available"]).to be false
      expect(pages["summary"]["available"]).to be false
    end

    it "should be the correct decision aid user" do
      get :options, slug: "test_decision_aid"
      body = JSON.parse(response.body)
      expect(body["meta"]["decision_aid_user"]["id"]).to eq(decision_aid_user.id)
    end

    it "should not be a new user" do
      get :options, slug: "test_decision_aid"
      body = JSON.parse(response.body)
      expect(body["meta"]["is_new_user"]).to be false
    end
  end
=end

  describe "properties" do

    before do
      decision_aid.intro_pages.each do |ip|
        create(:basic_page_submission, decision_aid_user_id: decision_aid_user.id, intro_page_id: ip.id)
      end

      decision_aid.demographic_questions.ordered.each do |q|
        if q.question_response_type == "radio"
          create(:decision_aid_user_response, decision_aid_user_id: decision_aid_user.id, question_id: q.id, question_response_id: q.question_responses.first.id)
        else
          create(:decision_aid_user_text_response, decision_aid_user_id: decision_aid_user.id, question_id: q.id)
        end
      end
    end

    it "should only be the properties and properties page available" do
      get :properties, params: {slug: "test_decision_aid"}
      body = JSON.parse(response.body)
      pages = body["meta"]["pages"]
      expect(pages["intro"]["available"]).to be true
      expect(pages["about"]["available"]).to be true
      expect(pages["properties"]["available"]).to be true
      expect(pages["results_#{decision_aid.sub_decisions.first.sub_decision_order}"]["available"]).to be false
      expect(pages["quiz"]["available"]).to be false
      expect(pages["summary"]["available"]).to be false
    end

    it "should be the correct decision aid user" do
      get :properties, params: {slug: "test_decision_aid"}
      body = JSON.parse(response.body)
      expect(body["meta"]["decision_aid_user"]["id"]).to eq(decision_aid_user.id)
    end

    it "should not be a new user" do
      get :properties, params: {slug: "test_decision_aid"}
      body = JSON.parse(response.body)
      expect(body["meta"]["is_new_user"]).to be false
    end
  end

  describe "dce" do
    let (:dce_decision_aid) { create(:dce_decision_aid, slug: "dce_decision_aid")}
    let (:decision_aid_user) { create(:decision_aid_user, decision_aid_id: dce_decision_aid.id) }

    before do
      dce_decision_aid.intro_pages.each do |ip|
        create(:basic_page_submission, decision_aid_user_id: decision_aid_user.id, intro_page_id: ip.id)
      end

      dce_decision_aid.demographic_questions.ordered.each do |q|
        if q.question_response_type == "radio"
          create(:decision_aid_user_response, decision_aid_user_id: decision_aid_user.id, question_id: q.id, question_response_id: q.question_responses.first.id)
        else
          create(:decision_aid_user_text_response, decision_aid_user_id: decision_aid_user.id, question_id: q.id)
        end
      end
    end

    it "should be intro, about, options, and dce page available" do
      get :dce, params: {slug: "dce_decision_aid"}
      body = JSON.parse(response.body)
      pages = body["meta"]["pages"]
      expect(pages["intro"]["available"]).to be true
      expect(pages["about"]["available"]).to be true
      expect(pages["dce"]["available"]).to be true
      expect(pages["results_#{decision_aid.sub_decisions.first.sub_decision_order}"]["available"]).to be false
      expect(pages["quiz"]["available"]).to be false
      expect(pages["summary"]["available"]).to be false
    end

    it "should be the correct decision aid user" do
      get :dce, params: {slug: "dce_decision_aid"}
      body = JSON.parse(response.body)
      expect(body["meta"]["decision_aid_user"]["id"]).to eq(decision_aid_user.id)
    end

    it "should not be a new user" do
      get :dce, params: {slug: "dce_decision_aid"}
      body = JSON.parse(response.body)
      expect(body["meta"]["is_new_user"]).to be false
    end

    it "should have no dce_question_set_responses if there is no current_question_set in the params" do
      get :dce, params: {slug: "dce_decision_aid"}
      body = JSON.parse(response.body)
      expect(body).to have_key "decision_aid"
      decision_aid = body["decision_aid"]
      expect(decision_aid).to have_key "dce_question_set_responses"
      expect(decision_aid["dce_question_set_responses"]).to be nil
    end

    it "should have dce_question_set_responses if there is a current_question_set in the params" do
      get :dce, params: {slug: "dce_decision_aid", current_question_set: 2}
      body = JSON.parse(response.body)
      expect(body).to have_key "decision_aid"
      decision_aid = body["decision_aid"]
      expect(decision_aid).to have_key "dce_question_set_responses"
      expect(decision_aid["dce_question_set_responses"].length).to be > 0
    end
  end

  describe "results" do

    before do
      decision_aid.intro_pages.each do |ip|
        create(:basic_page_submission, decision_aid_user_id: decision_aid_user.id, intro_page_id: ip.id)
      end

      decision_aid.demographic_questions.each do |q|
        if q.question_response_type == "radio"
          create(:decision_aid_user_response, decision_aid_user_id: decision_aid_user.id, question_id: q.id, question_response_id: q.question_responses.first.id)
        else
          create(:decision_aid_user_text_response, decision_aid_user_id: decision_aid_user.id, question_id: q.id)
        end
      end
      decision_aid.properties.each do |p|
        create(:decision_aid_user_property, property_id: p.id, decision_aid_user_id: decision_aid_user.id)
      end
    end

    it "should only be the results and results page available" do
      get :results, params: {sub_decision_order: decision_aid.sub_decisions.first.sub_decision_order, slug: "test_decision_aid"}
      body = JSON.parse(response.body)
      pages = body["meta"]["pages"]
      expect(pages["intro"]["available"]).to be true
      expect(pages["about"]["available"]).to be true
      expect(pages["properties"]["available"]).to be true
      expect(pages["results_#{decision_aid.sub_decisions.first.sub_decision_order}"]["available"]).to be true
      expect(pages["quiz"]["available"]).to be false
      expect(pages["summary"]["available"]).to be false
    end

    it "should be the correct decision aid user" do
      get :results, params: {sub_decision_order: decision_aid.sub_decisions.first.sub_decision_order, slug: "test_decision_aid"}
      body = JSON.parse(response.body)
      expect(body["meta"]["decision_aid_user"]["id"]).to eq(decision_aid_user.id)
    end

    it "should not be a new user" do
      get :results, params: {sub_decision_order: decision_aid.sub_decisions.first.sub_decision_order, slug: "test_decision_aid"}
      body = JSON.parse(response.body)
      expect(body["meta"]["is_new_user"]).to be false
    end
  end

  describe "quiz" do
    before do
      decision_aid.intro_pages.each do |ip|
        create(:basic_page_submission, decision_aid_user_id: decision_aid_user.id, intro_page_id: ip.id)
      end

      decision_aid.demographic_questions.ordered.each do |q|
        if q.question_response_type == "radio"
          create(:decision_aid_user_response, decision_aid_user_id: decision_aid_user.id, question_id: q.id, question_response_id: q.question_responses.first.id)
        else
          create(:decision_aid_user_text_response, decision_aid_user_id: decision_aid_user.id, question_id: q.id)
        end
      end
      decision_aid.properties.each do |p|
        create(:decision_aid_user_property, property_id: p.id, decision_aid_user_id: decision_aid_user.id)
      end
      sd = decision_aid.sub_decisions.first
      create(:decision_aid_user_sub_decision_choice, decision_aid_user_id: decision_aid_user.id, sub_decision_id: sd.id, option_id: decision_aid.options.first.id)
      #decision_aid_user.update_attribute(:selected_option_id, decision_aid.options.first.id)
    end

    it "should only be the quiz and quiz page available" do
      get :quiz, params: {slug: "test_decision_aid"}
      body = JSON.parse(response.body)
      pages = body["meta"]["pages"]
      expect(pages["intro"]["available"]).to be true
      expect(pages["about"]["available"]).to be true
      expect(pages["properties"]["available"]).to be true
      expect(pages["results_#{decision_aid.sub_decisions.first.sub_decision_order}"]["available"]).to be true
      expect(pages["quiz"]["available"]).to be true
      expect(pages["summary"]["available"]).to be false
    end

    it "should be the correct decision aid user" do
      get :quiz, params: {slug: "test_decision_aid"}
      body = JSON.parse(response.body)
      expect(body["meta"]["decision_aid_user"]["id"]).to eq(decision_aid_user.id)
    end

    it "should not be a new user" do
      get :quiz, params: {slug: "test_decision_aid"}
      body = JSON.parse(response.body)
      expect(body["meta"]["is_new_user"]).to be false
    end
  end

  describe "summary" do

    before do
      decision_aid.intro_pages.each do |ip|
        create(:basic_page_submission, decision_aid_user_id: decision_aid_user.id, intro_page_id: ip.id)
      end

      decision_aid.questions.each do |q|
        if q.question_response_type == "radio"
          create(:decision_aid_user_response, decision_aid_user_id: decision_aid_user.id, question_id: q.id, question_response_id: q.question_responses.first.id)
        else
          create(:decision_aid_user_text_response, decision_aid_user_id: decision_aid_user.id, question_id: q.id)
        end
      end
      decision_aid.properties.each do |p|
        create(:decision_aid_user_property, property_id: p.id, decision_aid_user_id: decision_aid_user.id)
      end
      sd = decision_aid.sub_decisions.first
      create(:decision_aid_user_sub_decision_choice, decision_aid_user_id: decision_aid_user.id, sub_decision_id: sd.id, option_id: decision_aid.options.first.id)
    end

    it "should only be the summary and summary page available" do
      get :summary, params: {slug: "test_decision_aid"}
      body = JSON.parse(response.body)
      pages = body["meta"]["pages"]
      expect(pages["intro"]["available"]).to be true
      expect(pages["about"]["available"]).to be true
      expect(pages["properties"]["available"]).to be true
      expect(pages["results_#{decision_aid.sub_decisions.first.sub_decision_order}"]["available"]).to be true
      expect(pages["quiz"]["available"]).to be true
      expect(pages["summary"]["available"]).to be true
    end

    it "should be the correct decision aid user" do
      get :summary, params: {slug: "test_decision_aid"}
      body = JSON.parse(response.body)
      expect(body["meta"]["decision_aid_user"]["id"]).to eq(decision_aid_user.id)
    end

    it "should not be a new user" do
      get :summary, params: {slug: "test_decision_aid"}
      body = JSON.parse(response.body)
      expect(body["meta"]["is_new_user"]).to be false
    end
  end

end