require "rails_helper"

RSpec.describe Api::StaticPagesController, :type => :controller do

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
  let (:static_page) { create(:static_page, decision_aid_id: decision_aid.id) }

  describe "create" do
    it "should create if a user is logged in", :user1 => true do
      new_static_page_attrs = FactoryGirl.attributes_for(:static_page, sub_decision_id: decision_aid.sub_decisions.first.id)
      post :create, params: {decision_aid_id: decision_aid.id, static_page: new_static_page_attrs}
      expect(response.status).to eq(200)
    end

    it "should not create if a user is not logged in" do
      new_static_page_attrs = FactoryGirl.attributes_for(:static_page)
      post :create, params: {decision_aid_id: decision_aid.id, static_page: new_static_page_attrs}
      expect(response.status).to eq(401)
    end
  end

  describe "show" do
    it "should render the static_page if the user is creator", :user1 => true do
      get :show, params: {decision_aid_id: decision_aid.id, id: static_page.id}
      expect(response.status).to eq(200)
    end

    it "should render the static_page if the user is the superadmin", :superuser => true do
      static_page.creator = user1
      static_page.save
      get :show, params: {decision_aid_id: decision_aid.id, id: static_page.id}
      expect(response.status).to eq(200)
    end

    it "should return 403 if the user is not the creator", :user1 => true do
      static_page.creator = user2
      static_page.save
      get :show, params: {decision_aid_id: decision_aid.id, id: static_page.id}
      expect(response.status).to eq(403)
    end

    it "should return 401 if no user is logged in" do
      get :show, params: {decision_aid_id: decision_aid.id, id: static_page.id}
      expect(response.status).to eq(401)
    end
  end

  describe "update" do
    it "should update the static_page if the user is creator", :user1 => true do
      update_params = {name: "1234"}
      put :update, params: {static_page: update_params, decision_aid_id: decision_aid.id, id: static_page.id}
      expect(response.status).to eq(200)
    end

    it "should update the static_page if the user is the superadmin", :superuser => true do
      static_page.creator = user1
      static_page.save
      update_params = {name: "1234"}
      put :update, params: {decision_aid_id: decision_aid.id, id: static_page.id, static_page: update_params}
      expect(response.status).to eq(200)
    end

    it "should return 403 if the user is not the creator", :user1 => true do
      static_page.creator = user2
      static_page.save
      put :update, params: {id: static_page.id, decision_aid_id: decision_aid.id}
      expect(response.status).to eq(403)
    end

    it "should return 401 if no user is logged in" do
      put :update, params: {id: static_page.id, decision_aid_id: decision_aid.id}
      expect(response.status).to eq(401)
    end
  end

  describe "destroy" do
    it "should destroy the static_page if the user is creator", :user1 => true do
      destroy_params = {name: "1234"}
      put :destroy, params: {static_page: destroy_params, decision_aid_id: decision_aid.id, id: static_page.id}
      expect(response.status).to eq(200)
    end

    it "should destroy the static_page if the user is the superadmin", :superuser => true do
      static_page.creator = user1
      static_page.save
      destroy_params = {name: "1234"}
      put :destroy, params: {decision_aid_id: decision_aid.id, id: static_page.id, static_page: destroy_params}
      expect(response.status).to eq(200)
    end

    it "should return 403 if the user is not the creator", :user1 => true do
      static_page.creator = user2
      static_page.save
      put :destroy, params: {id: static_page.id, decision_aid_id: decision_aid.id}
      expect(response.status).to eq(403)
    end

    it "should return 401 if no user is logged in" do
      put :destroy, params: {id: static_page.id, decision_aid_id: decision_aid.id}
      expect(response.status).to eq(401)
    end
  end

  describe "index" do
    it "should only show static_pages in decision aid", :user1 => true do
      da2 = create(:basic_decision_aid)
      sp1, sp2, sp3, sp4 = create(:static_page, decision_aid_id: decision_aid.id, page_slug: "slug_1"), 
                           create(:static_page, decision_aid_id: decision_aid.id, page_slug: "slug_2"), 
                           create(:static_page, decision_aid_id: decision_aid.id, page_slug: "slug_3"), 
                           create(:static_page, decision_aid_id: da2.id)
      get :index, params: {decision_aid_id: decision_aid.id}
      static_pages = JSON.parse(response.body)
      static_page_ids = static_pages["static_pages"].map{ |sp| sp["id"] }
      expect(static_page_ids).not_to include(sp4.id) and expect(static_page_ids).to include(sp3.id) and
      expect(static_page_ids).to include(sp2.id) and expect(static_page_ids).to include(sp1.id)
    end

    it "should return 401 if no user is logged in" do
      get :index, params: {decision_aid_id: decision_aid.id}
      expect(response.status).to eq(401)
    end
  end

  describe "update_order" do
    it "should change the static_page order if user has permission", :user1 => true do
      sp1, sp2 = create(:static_page, decision_aid_id: decision_aid.id, page_slug: "slug_1"), 
                 create(:static_page, decision_aid_id: decision_aid.id, page_slug: "slug_2")
      static_page_params = {static_page_order: 1}
      expect(sp2.static_page_order).to eq(2)
      put :update_order, params: {static_page: static_page_params, decision_aid_id: decision_aid.id, id: sp2.id}
      expect(sp2.reload.static_page_order).to eq(1)
    end

    it "should return 401 if no user is logged in" do
      sp1 = create(:static_page, decision_aid_id: decision_aid.id)
      static_page_params = {static_page_order: 1}
      put :update_order, params: {static_page: static_page_params, decision_aid_id: decision_aid.id, id: sp1.id}
      expect(response.status).to eq(401)
    end
  end
end