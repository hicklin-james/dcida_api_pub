require "rails_helper"

RSpec.describe Api::DecisionAidsController, :type => :controller do

  PROPERTY_LEVEL_COUNT ||= 5
  OPTION_COUNT ||= 3
  QUESTION_SET_LENGTH ||= 5

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

  let (:decision_aid) { create(:basic_decision_aid, slug: "test_decision_aid") }

  describe "create" do
    it "should create if a user is logged in", :superuser => true do
      new_da_attrs = FactoryGirl.attributes_for(:basic_decision_aid)
      post :create, params: {decision_aid: new_da_attrs}
      expect(response.status).to eq(200)
    end

    it "should not create if a user is not logged in" do
      new_da_attrs = FactoryGirl.attributes_for(:basic_decision_aid)
      post :create, params: {decision_aid: new_da_attrs}
      expect(response.status).to eq(401)
    end

    it "should render 422 error if the decision_aid doesn't save", superuser: true do
      new_da_attrs = FactoryGirl.attributes_for(:basic_decision_aid)
      new_da_attrs[:title] = ""
      post :create, params: {decision_aid: new_da_attrs}
      expect(response.status).to eq(422)
    end

    it "should not create if user isnt superuser", user1: true do
      new_da_attrs = FactoryGirl.attributes_for(:basic_decision_aid)
      post :create, params: {decision_aid: new_da_attrs}
      expect(response.status).to eq(403)
    end
  end

  describe "show" do
    it "should render the decision aid if the user is creator", :user1 => true do
      get :show, params: { id: decision_aid.id }
      expect(response.status).to eq(200)
    end

    it "should render the decision aid if the user is the superadmin", :superuser => true do
      decision_aid.creator = user1
      decision_aid.save
      get :show, params: { id: decision_aid.id }
      expect(response.status).to eq(200)
    end

    it "should return 403 if the user is not the creator", :user1 => true do
      decision_aid.creator = user2
      decision_aid.save
      get :show, params: { id: decision_aid.id }
      expect(response.status).to eq(403)
    end

    it "should return 401 if no user is logged in" do
      get :show, params: { id: decision_aid.id }
      expect(response.status).to eq(401)
    end
  end

  describe "update" do
    it "should update the decision aid if the user is creator", :user1 => true do
      update_params = {name: "1234"}
      put :update, params: {decision_aid: update_params, id: decision_aid.id}
      expect(response.status).to eq(200)
    end

    it "should update the decision aid if the user is the superadmin", :superuser => true do
      decision_aid.creator = user1
      decision_aid.save
      update_params = {name: "1234"}
      put :update, params: {decision_aid: update_params, id: decision_aid.id}
      expect(response.status).to eq(200)
    end

    it "should return 403 if the user is not the creator", :user1 => true do
      decision_aid.creator = user2
      decision_aid.save
      put :update, params: {id: decision_aid.id}
      expect(response.status).to eq(403)
    end

    it "should return 401 if no user is logged in" do
      put :update, params: {id: decision_aid.id}
      expect(response.status).to eq(401)
    end

    it "should render 422 error if the decision_aid doesn't save", user1: true do
      put :update, params: {decision_aid: {title: ""}, id: decision_aid.id}
      expect(response.status).to eq(422)
    end
  end

  describe "destroy" do
    it "should destroy the decision aid if the user is creator", :user1 => true do
      put :destroy, params: {id: decision_aid.id}
      expect(response.status).to eq(200)
    end

    it "should destroy the decision aid if the user is the superadmin", :superuser => true do
      decision_aid.creator = user1
      decision_aid.save
      put :destroy, params: {id: decision_aid.id}
      expect(response.status).to eq(200)
    end

    it "should return 403 if the user is not the creator", :user1 => true do
      decision_aid.creator = user2
      decision_aid.save
      put :destroy, params: {id: decision_aid.id}
      expect(response.status).to eq(403)
    end

    it "should return 401 if no user is logged in" do
      put :destroy, params: {id: decision_aid.id}
      expect(response.status).to eq(401)
    end
  end

  describe "index" do
    it "should only show decision aids created by the logged in user", :user1 => true do
      da1, da2, da3, da4 = create(:basic_decision_aid), create(:basic_decision_aid), create(:basic_decision_aid), create(:basic_decision_aid)
      da4.creator = user2
      da4.save
      get :index
      decision_aids = JSON.parse(response.body)
      decision_aid_ids = decision_aids["decision_aids"].map{ |da| da["id"] }
      expect(decision_aid_ids).not_to include(da4.id) and expect(decision_aid_ids).to include(da3.id) and
      expect(decision_aid_ids).to include(da2.id) and expect(decision_aid_ids).to include(da1.id)
    end

    it "should show all the decision aids if the logged in user is a superadmin", :superuser => true do
      da1, da2, da3, da4 = create(:basic_decision_aid), create(:basic_decision_aid), create(:basic_decision_aid), create(:basic_decision_aid)
      da1.creator, da2.creator, da3.creator, da4.creator = user2, user2, user2, user2
      da1.save and da2.save and da3.save and da4.save
      get :index
      decision_aids = JSON.parse(response.body)
      decision_aid_ids = decision_aids["decision_aids"].map{ |da| da["id"] }
      expect(decision_aid_ids).to include(da4.id) and expect(decision_aid_ids).to include(da3.id) and
      expect(decision_aid_ids).to include(da2.id) and expect(decision_aid_ids).to include(da1.id)
    end

    it "should return 401 if no user is logged in" do
      get :index
      expect(response.status).to eq(401)
    end
  end

  describe "preview" do
    it "should render the decision aid if the user is creator", :user1 => true do
      get :preview, params: {id: decision_aid.id}
      expect(response.status).to eq(200)
    end

    it "should render the decision aid if the user is the superadmin", :superuser => true do
      decision_aid.creator = user1
      decision_aid.save
      get :preview, params: {id: decision_aid.id}
      expect(response.status).to eq(200)
    end

    it "should return 403 if the user is not the creator", :user1 => true do
      decision_aid.creator = user2
      decision_aid.save
      get :preview, params: {id: decision_aid.id}
      expect(response.status).to eq(403)
    end

    it "should return 401 if no user is logged in" do
      get :preview, params: {id: decision_aid.id}
      expect(response.status).to eq(401)
    end
  end

  describe "upload_dce_design" do
    it "should render the decision aid if the user is the creator", :user1 => true do
      post :upload_dce_design, params: {id: decision_aid.id}
      expect(response.status).to eq(200)
    end

    it "should render the decision aid if the user is the superadmin", :superuser => true do
      post :upload_dce_design, params: {id: decision_aid.id}
      expect(response.status).to eq(200)
    end

    it "should return 403 if the user is not the creator", :user1 => true do
      decision_aid.creator = user2
      decision_aid.save
      post :upload_dce_design, params: {id: decision_aid.id}
      expect(response.status).to eq 403
    end

    it "should return 401 if no user is logged in" do
      post :upload_dce_design, params: {id: decision_aid.id}
      expect(response.status).to eq 401
    end

    it "should start a background job from the DceDesignUploadWorker", :user1 => true do
      expect(DceDesignUploadWorker.jobs.size).to eq 0
      post :upload_dce_design, params: {id: decision_aid.id}
      expect(DceDesignUploadWorker.jobs.size).to eq 1
    end
  end

  describe "upload_dce_results" do
    it "should render the decision aid if the user is the creator", :user1 => true do
      post :upload_dce_results, params: { id: decision_aid.id }
      expect(response.status).to eq(200)
    end

    it "should render the decision aid if the user is the superadmin", :superuser => true do
      post :upload_dce_results, params: { id: decision_aid.id }
      expect(response.status).to eq(200)
    end

    it "should return 403 if the user is not the creator", :user1 => true do
      decision_aid.creator = user2
      decision_aid.save
      post :upload_dce_results, params: { id: decision_aid.id }
      expect(response.status).to eq 403
    end

    it "should return 401 if no user is logged in" do
      post :upload_dce_results, params: { id: decision_aid.id }
      expect(response.status).to eq 401
    end

    it "should start a background job from the DceResultsUploadWorker", :user1 => true do
      expect(DceResultsUploadWorker.jobs.size).to eq 0
      post :upload_dce_results, params: { id: decision_aid.id }
      expect(DceResultsUploadWorker.jobs.size).to eq 1
    end
  end

  describe "upload_bw_design" do
    it "should render the decision aid if the user is the creator", :user1 => true do
      post :upload_bw_design, params: { id: decision_aid.id }
      expect(response.status).to eq(200)
    end

    it "should render the decision aid if the user is the superadmin", :superuser => true do
      post :upload_bw_design, params: { id: decision_aid.id }
      expect(response.status).to eq(200)
    end

    it "should return 403 if the user is not the creator", :user1 => true do
      decision_aid.creator = user2
      decision_aid.save
      post :upload_bw_design, params: { id: decision_aid.id }
      expect(response.status).to eq 403
    end

    it "should return 401 if no user is logged in" do
      post :upload_bw_design, params: { id: decision_aid.id }
      expect(response.status).to eq 401
    end

    it "should start a background job from the BwDesignUploadWorker", :user1 => true do
      expect(BwDesignUploadWorker.jobs.size).to eq 0
      post :upload_bw_design, params: { id: decision_aid.id }
      expect(BwDesignUploadWorker.jobs.size).to eq 1
    end
  end

  describe "setup_dce" do
    it "should render a download_item if the user is the creator", :user1 => true do
      get :setup_dce, params: { id: decision_aid.id }
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)).to have_key "download_item"
    end

    it "should render a download_item  if the user is the superadmin", :superuser => true do
      get :setup_dce, params: { id: decision_aid.id }
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)).to have_key "download_item"
    end

    it "should return 403 if the user is not the creator", :user1 => true do
      decision_aid.creator = user2
      decision_aid.save
      get :setup_dce, params: { id: decision_aid.id }
      expect(response.status).to eq 403
    end

    it "should return 401 if no user is logged in" do
      get :setup_dce, params: { id: decision_aid.id }
      expect(response.status).to eq 401
    end

    it "should start a background job from the DceTemplateWorker", :user1 => true do
      expect(DceTemplateWorker.jobs.size).to eq 0
      get :setup_dce, params: { id: decision_aid.id }
      expect(DceTemplateWorker.jobs.size).to eq 1
    end
  end

  describe "setup_bw" do
    it "should render a download_item if the user is the creator", :user1 => true do
      get :setup_bw, params: { id: decision_aid.id }
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)).to have_key "download_item"
    end

    it "should render a download_item  if the user is the superadmin", :superuser => true do
      get :setup_bw, params: { id: decision_aid.id }
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)).to have_key "download_item"
    end

    it "should return 403 if the user is not the creator", :user1 => true do
      decision_aid.creator = user2
      decision_aid.save
      get :setup_bw, params: { id: decision_aid.id }
      expect(response.status).to eq 403
    end

    it "should return 401 if no user is logged in" do
      get :setup_bw, params: { id: decision_aid.id }
      expect(response.status).to eq 401
    end

    it "should start a background job from the BwTemplateWorker", :user1 => true do
      expect(BwTemplateWorker.jobs.size).to eq 0
      get :setup_bw, params: { id: decision_aid.id }
      expect(BwTemplateWorker.jobs.size).to eq 1
    end
  end

  describe "export" do
    it "should render a download_item if the user is the creator", :user1 => true do
      get :export, params: { id: decision_aid.id }
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)).to have_key "download_item"
    end

    it "should render a download_item  if the user is the superadmin", :superuser => true do
      get :export, params: { id: decision_aid.id }
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)).to have_key "download_item"
    end

    it "should return 403 if the user is not the creator", :user1 => true do
      decision_aid.creator = user2
      decision_aid.save
      get :export, params: { id: decision_aid.id }
      expect(response.status).to eq 403
    end

    it "should return 401 if no user is logged in" do
      get :export, params: { id: decision_aid.id }
      expect(response.status).to eq 401
    end

    it "should start a background job from the ExportWorker", :user1 => true do
      expect(ExportWorker.jobs.size).to eq 0
      get :export, params: { id: decision_aid.id }
      expect(ExportWorker.jobs.size).to eq 1
    end
  end
end