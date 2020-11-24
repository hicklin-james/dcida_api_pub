require "rails_helper"

RSpec.describe Api::AccordionsController, :type => :controller do

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

  let (:decision_aid) { create(:full_decision_aid, slug: "test_decision_aid") }
  let (:other_decision_aid) { create(:full_decision_aid, slug: "other_test_decision_aid") }
  let (:accordion) { create(:accordion, user_id: user1.id, decision_aid_id: decision_aid.id) }

  describe "create" do
    it "should create if a user is logged in and decision aid exists", :user1 => true do
      new_accordion_attrs = FactoryGirl.attributes_for(:accordion)
      post :create, params: {decision_aid_id: decision_aid.id, accordion: new_accordion_attrs}
      expect(response.status).to eq(200)
    end

    it "should not create if a user is not logged in" do
      new_accordion_attrs = FactoryGirl.attributes_for(:accordion)
      post :create, params: {decision_aid_id: decision_aid.id, accordion: new_accordion_attrs}
      expect(response.status).to eq(401)
    end
  end

  describe "update" do
    it "should update the accordion if the user is creator", :user1 => true do
      update_params = {title: "1234"}
      put :update, params: {accordion: update_params, decision_aid_id: decision_aid.id, id: accordion.id}
      expect(response.status).to eq(200)
    end

    it "should update the accordion if the user is the superadmin", :superuser => true do
      accordion.user_id = user1.id
      accordion.save
      update_params = {title: "1234"}
      put :update, params: {decision_aid_id: decision_aid.id, id: accordion.id, accordion: update_params}
      expect(response.status).to eq(200)
    end

    it "should return 403 if the user is not the creator", :user1 => true do
      accordion.user_id = user2.id
      accordion.save
      put :update, params: {id: accordion.id, decision_aid_id: decision_aid.id}
      expect(response.status).to eq(403)
    end

    it "should return 401 if no user is logged in" do
      put :update, params: {id: accordion.id, decision_aid_id: decision_aid.id}
      expect(response.status).to eq(401)
    end
  end

  describe "destroy" do
    it "should destroy the accordion if the user is creator", :user1 => true do
      destroy_params = {name: "1234"}
      put :destroy, params: {accordion: destroy_params, decision_aid_id: decision_aid.id, id: accordion.id}
      expect(response.status).to eq(200)
    end

    it "should destroy the accordion if the user is the superadmin", :superuser => true do
      accordion.user_id = user1.id
      accordion.save
      destroy_params = {name: "1234"}
      put :destroy, params: {decision_aid_id: decision_aid.id, id: accordion.id, accordion: destroy_params}
      expect(response.status).to eq(200)
    end

    it "should return 403 if the user is not the creator", :user1 => true do
      accordion.user_id = user2.id
      accordion.save
      put :destroy, params: {id: accordion.id, decision_aid_id: decision_aid.id}
      expect(response.status).to eq(403)
    end

    it "should return 401 if no user is logged in" do
      put :destroy, params: {id: accordion.id, decision_aid_id: decision_aid.id}
      expect(response.status).to eq(401)
    end
  end

  describe "index" do
    it "should only show accordions scoped to decision aid", :user1 => true do
      a1, a2, a3, a4 = create(:accordion, decision_aid_id: decision_aid.id, user_id: user1.id), create(:accordion, decision_aid_id: decision_aid.id, user_id: user1.id), create(:accordion, decision_aid_id: decision_aid.id, user_id: user1.id), create(:accordion, decision_aid_id: other_decision_aid.id, user_id: user1.id)
      get :index, params: {decision_aid_id: decision_aid.id}
      accordions = JSON.parse(response.body)
      accordion_ids = accordions["accordions"].map{ |o| o["id"] }
      expect(accordion_ids).not_to include(a4.id) and expect(accordion_ids).to include(a3.id) and
      expect(accordion_ids).to include(a2.id) and expect(accordion_ids).to include(a1.id)
    end

    it "should return 401 if no user is logged in" do
      get :index, params: {decision_aid_id: decision_aid.id}
      expect(response.status).to eq(401)
    end
  end
end