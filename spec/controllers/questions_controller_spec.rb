require "rails_helper"

RSpec.describe Api::QuestionsController, :type => :controller do

  let(:user1) { create(:user) }
  let(:token1) { double :acceptable? => true, :resource_owner_id => user1.id }

  let(:user2) { create(:user) }
  let(:token2) { double :acceptable? => true, :resource_owner_id => user2.id }

  let(:superuser) { create(:superuser) }
  let(:token3) { double :acceptable? => true, :resource_owner_id => superuser.id }

  before(:each, user1: true) do
    User.current_user = user1
    allow(controller).to receive(:doorkeeper_token) {token1}
  end

  before(:each, user2: true) do
    User.current_user = user2
    allow(controller).to receive(:doorkeeper_token) {token2}
  end

  before(:each, :superuser) do
    User.current_user = superuser
    allow(controller).to receive(:doorkeeper_token) {token3}
  end

  let (:decision_aid) { create(:basic_decision_aid) }
  let (:question_page) { create(:question_page, decision_aid_id: decision_aid.id, section: "about") }
  let (:question) { create(:demo_radio_question, question_order: 0, decision_aid_id: decision_aid.id) }

  describe "create" do
    it "should create if a user is logged in", :user1 => true do
      new_question_attrs = FactoryGirl.attributes_for(:demo_radio_question, question_type: "demographic", question_response_type: "radio", question_response_style: "horizontal_radio", question_page_id: question_page.id)
      response_attrs = FactoryGirl.attributes_for(:question_response, decision_aid_id: decision_aid.id, question_response_order: 1)
      new_question_attrs[:question_responses_attributes] = [response_attrs]
      post :create, params: {decision_aid_id: decision_aid.id, question_order: 0, question: new_question_attrs}
      expect(response.status).to eq(200)
    end

    it "should not create if a user is not logged in" do
      new_question_attrs = FactoryGirl.attributes_for(:demo_radio_question, question_order: 0)
      post :create, params: {decision_aid_id: decision_aid.id, question: new_question_attrs}
      expect(response.status).to eq(401)
    end
  end

  describe "show" do
    it "should render the question if the user is creator", :user1 => true do
      get :show, params: {decision_aid_id: decision_aid.id, id: question.id}
      expect(response.status).to eq(200)
    end

    it "should render the question if the user is the superadmin", :superuser => true do
      question.creator = user1
      question.save
      get :show, params: {decision_aid_id: decision_aid.id, id: question.id}
      expect(response.status).to eq(200)
    end

    it "should return 403 if the user is not the creator", :user1 => true do
      question.creator = user2
      question.save
      get :show, params: {decision_aid_id: decision_aid.id, id: question.id}
      expect(response.status).to eq(403)
    end

    it "should return 401 if no user is logged in" do
      get :show, params: {decision_aid_id: decision_aid.id, id: question.id}
      expect(response.status).to eq(401)
    end
  end

  describe "update" do
    it "should update the question if the user is creator", :user1 => true do
      update_params = {name: "1234"}
      put :update, params: {question: update_params, decision_aid_id: decision_aid.id, id: question.id}
      expect(response.status).to eq(200)
    end

    it "should update the question if the user is the superadmin", :superuser => true do
      question.creator = user1
      question.save
      update_params = {name: "1234"}
      put :update, params: {decision_aid_id: decision_aid.id, id: question.id, question: update_params}
      expect(response.status).to eq(200)
    end

    it "should return 403 if the user is not the creator", :user1 => true do
      question.creator = user2
      question.save
      put :update, params: {id: question.id, decision_aid_id: decision_aid.id}
      expect(response.status).to eq(403)
    end

    it "should return 401 if no user is logged in" do
      put :update, params: {id: question.id, decision_aid_id: decision_aid.id}
      expect(response.status).to eq(401)
    end
  end

  describe "destroy" do
    it "should destroy the question if the user is creator", :user1 => true do
      destroy_params = {name: "1234"}
      put :destroy, params: {question: destroy_params, decision_aid_id: decision_aid.id, id: question.id}
      expect(response.status).to eq(200)
    end

    it "should destroy the question if the user is the superadmin", :superuser => true do
      question.creator = user1
      question.save
      destroy_params = {name: "1234"}
      put :destroy, params: {decision_aid_id: decision_aid.id, id: question.id, question: destroy_params}
      expect(response.status).to eq(200)
    end

    it "should return 403 if the user is not the creator", :user1 => true do
      question.creator = user2
      question.save
      put :destroy, params: {id: question.id, decision_aid_id: decision_aid.id}
      expect(response.status).to eq(403)
    end

    it "should return 401 if no user is logged in" do
      put :destroy, params: {id: question.id, decision_aid_id: decision_aid.id}
      expect(response.status).to eq(401)
    end
  end

  describe "index" do
    it "should only show questions in decision aid", :user1 => true do
      da2 = create(:basic_decision_aid)
      q1, q2, q3, q4 = create(:demo_radio_question, question_order: 0, decision_aid_id: decision_aid.id), 
                       create(:demo_radio_question, question_order: 1, decision_aid_id: decision_aid.id), 
                       create(:demo_radio_question, question_order: 2, decision_aid_id: decision_aid.id), 
                       create(:demo_radio_question, question_order: 3, decision_aid_id: da2.id)
      get :index, params: {decision_aid_id: decision_aid.id}
      questions = JSON.parse(response.body)
      question_ids = questions["questions"].map{ |o| o["id"] }
      expect(question_ids).not_to include(q4.id) and expect(question_ids).to include(q3.id) and
      expect(question_ids).to include(q2.id) and expect(question_ids).to include(q1.id)
    end

    it "should filter by the question type in the params if demographic", :user1 => true do
      q1 = create(:demo_radio_question, decision_aid: decision_aid)
      q2 = create(:quiz_radio_question, decision_aid: decision_aid)
      get :index, params: {decision_aid_id: decision_aid.id, question_type: "demographic"}
      questions = JSON.parse(response.body)
      expect(questions["questions"].first["id"]).to eq q1.id
    end

    it "should filter by the question type in the params if quiz", :user1 => true do
      q1 = create(:demo_radio_question, decision_aid: decision_aid)
      q2 = create(:quiz_radio_question, decision_aid: decision_aid)
      get :index, params: {decision_aid_id: decision_aid.id, question_type: "quiz"}
      questions = JSON.parse(response.body)
      expect(questions["questions"].first["id"]).to eq q2.id
    end

    it "should include responses if params has include_responses", :user1 => true do
      q = create(:demo_radio_question, decision_aid: decision_aid)
      get :index, params: {decision_aid_id: decision_aid.id, include_responses: "true"}
      questions = JSON.parse(response.body)["questions"]
      q_response = questions.first
      expect(q_response["id"]).to eq q.id
      expect(q_response).to have_key "question_responses"
      expect(q_response["question_responses"].length).to be > 0
    end

    it "should include grid_questions of grid question", user1: true do
      q = create(:demo_grid_question, decision_aid: decision_aid)
      get :index, params: {decision_aid_id: decision_aid.id, include_responses: "true"}
      questions = JSON.parse(response.body)["questions"]
      q_response = questions.first
      expect(q_response["id"]).to eq q.id
      expect(q_response["grid_questions"].length).to be > 0
    end

    it "should return 401 if no user is logged in" do
      get :index, params: {decision_aid_id: decision_aid.id}
      expect(response.status).to eq(401)
    end
  end

  describe "preview" do
    it "should only show questions in the decision aid", :user1 => true do
      da2 = create(:basic_decision_aid)
      q1, q2, q3, q4 = create(:demo_radio_question, question_order: 0, decision_aid_id: decision_aid.id), 
                       create(:demo_radio_question, question_order: 1, decision_aid_id: decision_aid.id), 
                       create(:demo_radio_question, question_order: 2, decision_aid_id: decision_aid.id), 
                       create(:demo_radio_question, question_order: 3, decision_aid_id: da2.id)
      get :preview, params: {decision_aid_id: decision_aid.id}
      questions = JSON.parse(response.body)
      question_ids = questions["questions"].map{ |o| o["id"] }
      expect(question_ids).not_to include(q4.id) and expect(question_ids).to include(q3.id) and
      expect(question_ids).to include(q2.id) and expect(question_ids).to include(q1.id)
    end

    it "should filter by the question type in the params if demographic", :user1 => true do
      q1 = create(:demo_radio_question, decision_aid: decision_aid)
      q2 = create(:quiz_radio_question, decision_aid: decision_aid)
      get :preview, params: {decision_aid_id: decision_aid.id, question_type: "demographic"}
      questions = JSON.parse(response.body)
      expect(questions["questions"].first["id"]).to eq q1.id
    end

    it "should filter by the question type in the params if quiz", :user1 => true do
      q1 = create(:demo_radio_question, decision_aid: decision_aid)
      q2 = create(:quiz_radio_question, decision_aid: decision_aid)
      get :preview, params: {decision_aid_id: decision_aid.id, question_type: "quiz"}
      questions = JSON.parse(response.body)
      expect(questions["questions"].first["id"]).to eq q2.id
    end

    it "should return 401 if no user is logged in" do
      get :preview, params: {decision_aid_id: decision_aid.id}
      expect(response.status).to eq(401)
    end
  end

  describe "update_order" do
    # it "should change the question order if user has permission", :user1 => true do
    #   q1 = create(:demo_radio_question, decision_aid: decision_aid)
    #   q2 = create(:demo_radio_question, decision_aid: decision_aid)
    #   question_params = {question_order: 1}
    #   expect(q2.question_order).to eq(2)
    #   put :update_order, params: {question: question_params, decision_aid_id: decision_aid.id, id: q2.id}
    #   expect(q2.reload.question_order).to eq(1)
    # end

    it "should return 401 if no user is logged in" do
      q1 = create(:demo_radio_question, decision_aid: decision_aid)
      question_params = {question_order: 1}
      put :update_order, params: {question: question_params, decision_aid_id: decision_aid.id, id: q1.id}
      expect(response.status).to eq(401)
    end
  end

# Currently unsupported
=begin
  describe "clone" do
    it "should render the cloned question if the user is creator", :user1 => true do
      post :clone, params: {decision_aid_id: decision_aid.id, id: question.id}
      expect(response.status).to eq(200)
    end

    it "should render the cloned question if the user is the superadmin", :superuser => true do
      question.creator = user1
      question.save
      post :clone, params: {decision_aid_id: decision_aid.id, id: question.id}
      expect(response.status).to eq(200)
    end

    it "should increase the question count", :user1 => true do
      question.reload # updates count
      expect{post(:clone, params: {decision_aid_id: decision_aid.id, id: question.id})}
        .to change{Question.count}.by(1)
    end

    it "should return 403 if the user is not the creator", :user1 => true do
      question.creator = user2
      question.save
      post :clone, params: {decision_aid_id: decision_aid.id, id: question.id}
      expect(response.status).to eq(403)
    end

    it "should return 401 if no user is logged in" do
      post :clone, params: {decision_aid_id: decision_aid.id, id: question.id}
      expect(response.status).to eq(401)
    end
  end
=end
end