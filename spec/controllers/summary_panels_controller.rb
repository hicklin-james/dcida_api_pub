require "rails_helper"

RSpec.describe Api::SummaryPanelsController, :type => :controller do

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
  let (:summary_page) { create(:summary_page, decision_aid_id: decision_aid.id)}
  let (:summary_panel) { create(:summary_panel, decision_aid_id: decision_aid.id, panel_type: 0, summary_panel_order: 1) }


  describe "create" do
    it "should create if a user is logged in", :user1 => true do
      new_summary_panel_attrs = FactoryGirl.attributes_for(:summary_panel, panel_type: "text")
      new_summary_panel_attrs[:summary_page_id] = summary_page.id
      post :create, params: {decision_aid_id: decision_aid.id, summary_panel: new_summary_panel_attrs}
      expect(response.status).to eq(200)
    end

    it "should not create if a user is not logged in" do
      new_summary_panel_attrs = FactoryGirl.attributes_for(:summary_panel, panel_type: "text")
      post :create, params: {decision_aid_id: decision_aid.id, summary_panel: new_summary_panel_attrs}
      expect(response.status).to eq(401)
    end
  end

  describe "show" do
    it "should render the summary_panel if the user is creator", :user1 => true do
      get :show, params: {decision_aid_id: decision_aid.id, id: summary_panel.id}
      expect(response.status).to eq(200)
    end

    it "should render the summary_panel if the user is the superadmin", :superuser => true do
      summary_panel.creator = user1
      summary_panel.save
      get :show, params: {decision_aid_id: decision_aid.id, id: summary_panel.id}
      expect(response.status).to eq(200)
    end

    it "should return 403 if the user is not the creator", :user1 => true do
      summary_panel.creator = user2
      summary_panel.save
      get :show, params: {decision_aid_id: decision_aid.id, id: summary_panel.id}
      expect(response.status).to eq(403)
    end

    it "should return 401 if no user is logged in" do
      get :show, params: {decision_aid_id: decision_aid.id, id: summary_panel.id}
      expect(response.status).to eq(401)
    end
  end

  describe "update" do
    it "should update the summary_panel if the user is creator", :user1 => true do
      update_params = {panel_information: "test"}
      put :update, params: {summary_panel: update_params, decision_aid_id: decision_aid.id, id: summary_panel.id}
      expect(response.status).to eq(200)
    end

    it "should update the summary_panel if the user is the superadmin", :superuser => true do
      summary_panel.creator = user1
      summary_panel.save
      update_params = {panel_information: "test"}
      put :update, params: {decision_aid_id: decision_aid.id, id: summary_panel.id, summary_panel: update_params}
      expect(response.status).to eq(200)
    end

    it "should return 403 if the user is not the creator", :user1 => true do
      summary_panel.creator = user2
      summary_panel.save
      put :update, params: {id: summary_panel.id, decision_aid_id: decision_aid.id}
      expect(response.status).to eq(403)
    end

    it "should return 401 if no user is logged in" do
      put :update, params: {id: summary_panel.id, decision_aid_id: decision_aid.id}
      expect(response.status).to eq(401)
    end
  end

  describe "destroy" do
    it "should destroy the summary_panel if the user is creator", :user1 => true do
      destroy_params = {name: "1234"}
      put :destroy, params: {summary_panel: destroy_params, decision_aid_id: decision_aid.id, id: summary_panel.id}
      expect(response.status).to eq(200)
    end

    it "should destroy the summary_panel if the user is the superadmin", :superuser => true do
      summary_panel.creator = user1
      summary_panel.save
      destroy_params = {name: "1234"}
      put :destroy, params: {decision_aid_id: decision_aid.id, id: summary_panel.id, summary_panel: destroy_params}
      expect(response.status).to eq(200)
    end

    it "should return 403 if the user is not the creator", :user1 => true do
      summary_panel.creator = user2
      summary_panel.save
      put :destroy, params: {id: summary_panel.id, decision_aid_id: decision_aid.id}
      expect(response.status).to eq(403)
    end

    it "should return 401 if no user is logged in" do
      put :destroy, params: {id: summary_panel.id, decision_aid_id: decision_aid.id}
      expect(response.status).to eq(401)
    end
  end

  describe "index" do
    it "should only show summary_panels in decision aid", :user1 => true do
      da2 = create(:basic_decision_aid)
      p1, p2, p3, p4 = create(:summary_panel, decision_aid_id: decision_aid.id, panel_type: 0, summary_panel_order: 1), 
                       create(:summary_panel, decision_aid_id: decision_aid.id, panel_type: 0, summary_panel_order: 2), 
                       create(:summary_panel, decision_aid_id: decision_aid.id, panel_type: 0, summary_panel_order: 3), 
                       create(:summary_panel, decision_aid_id: da2.id, panel_type: 0, summary_panel_order: 1)
      get :index, params: {decision_aid_id: decision_aid.id}
      summary_panels = JSON.parse(response.body)
      summary_panel_ids = summary_panels["summary_panels"].map{ |p| p["id"] }
      expect(summary_panel_ids).not_to include(p4.id) and expect(summary_panel_ids).to include(p3.id) and
      expect(summary_panel_ids).to include(p2.id) and expect(summary_panel_ids).to include(p1.id)
    end

    it "should return 401 if no user is logged in" do
      get :index, params: {decision_aid_id: decision_aid.id}
      expect(response.status).to eq(401)
    end
  end
end