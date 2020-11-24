require "rails_helper"

RSpec.describe Api::PropertiesController, :type => :controller do

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
  let (:property) { create(:property, decision_aid_id: decision_aid.id) }

  describe "create" do
    it "should create if a user is logged in", :user1 => true do
      new_property_attrs = FactoryGirl.attributes_for(:property)
      post :create, params: {decision_aid_id: decision_aid.id, property: new_property_attrs}
      expect(response.status).to eq(200)
    end

    it "should not create if a user is not logged in" do
      new_property_attrs = FactoryGirl.attributes_for(:property)
      post :create, params: {decision_aid_id: decision_aid.id, property: new_property_attrs}
      expect(response.status).to eq(401)
    end
  end

  describe "show" do
    it "should render the property if the user is creator", :user1 => true do
      get :show, params: {decision_aid_id: decision_aid.id, id: property.id}
      expect(response.status).to eq(200)
    end

    it "should render the property if the user is the superadmin", :superuser => true do
      property.creator = user1
      property.save
      get :show, params: {decision_aid_id: decision_aid.id, id: property.id}
      expect(response.status).to eq(200)
    end

    it "should return 403 if the user is not the creator", :user1 => true do
      property.creator = user2
      property.save
      get :show, params: {decision_aid_id: decision_aid.id, id: property.id}
      expect(response.status).to eq(403)
    end

    it "should return 401 if no user is logged in" do
      get :show, params: {decision_aid_id: decision_aid.id, id: property.id}
      expect(response.status).to eq(401)
    end
  end

  describe "update" do
    it "should update the property if the user is creator", :user1 => true do
      update_params = {name: "1234"}
      put :update, params: {property: update_params, decision_aid_id: decision_aid.id, id: property.id}
      expect(response.status).to eq(200)
    end

    it "should update the property if the user is the superadmin", :superuser => true do
      property.creator = user1
      property.save
      update_params = {name: "1234"}
      put :update, params: {decision_aid_id: decision_aid.id, id: property.id, property: update_params}
      expect(response.status).to eq(200)
    end

    it "should return 403 if the user is not the creator", :user1 => true do
      property.creator = user2
      property.save
      put :update, params: {id: property.id, decision_aid_id: decision_aid.id}
      expect(response.status).to eq(403)
    end

    it "should return 401 if no user is logged in" do
      put :update, params: {id: property.id, decision_aid_id: decision_aid.id}
      expect(response.status).to eq(401)
    end
  end

  describe "destroy" do
    it "should destroy the property if the user is creator", :user1 => true do
      destroy_params = {name: "1234"}
      put :destroy, params: {property: destroy_params, decision_aid_id: decision_aid.id, id: property.id}
      expect(response.status).to eq(200)
    end

    it "should destroy the property if the user is the superadmin", :superuser => true do
      property.creator = user1
      property.save
      destroy_params = {name: "1234"}
      put :destroy, params: {decision_aid_id: decision_aid.id, id: property.id, property: destroy_params}
      expect(response.status).to eq(200)
    end

    it "should return 403 if the user is not the creator", :user1 => true do
      property.creator = user2
      property.save
      put :destroy, params: {id: property.id, decision_aid_id: decision_aid.id}
      expect(response.status).to eq(403)
    end

    it "should return 401 if no user is logged in" do
      put :destroy, params: {id: property.id, decision_aid_id: decision_aid.id}
      expect(response.status).to eq(401)
    end
  end

  describe "index" do
    it "should only show properties in decision aid", :user1 => true do
      da2 = create(:basic_decision_aid)
      p1, p2, p3, p4 = create(:property, decision_aid_id: decision_aid.id), create(:property, decision_aid_id: decision_aid.id), create(:property, decision_aid_id: decision_aid.id), create(:property, decision_aid_id: da2.id)
      get :index, params: {decision_aid_id: decision_aid.id}
      properties = JSON.parse(response.body)
      property_ids = properties["properties"].map{ |p| p["id"] }
      expect(property_ids).not_to include(p4.id) and expect(property_ids).to include(p3.id) and
      expect(property_ids).to include(p2.id) and expect(property_ids).to include(p1.id)
    end

    it "should return 401 if no user is logged in" do
      get :index, params: {decision_aid_id: decision_aid.id}
      expect(response.status).to eq(401)
    end
  end

  describe "preview" do
    it "should only show properties in the decision aid", :user1 => true do
      da2 = create(:basic_decision_aid)
      p1, p2, p3, p4 = create(:property, decision_aid_id: decision_aid.id), 
                       create(:property, decision_aid_id: decision_aid.id), 
                       create(:property, decision_aid_id: decision_aid.id), 
                       create(:property, decision_aid_id: da2.id)
      get :preview, params: {decision_aid_id: decision_aid.id}
      properties = JSON.parse(response.body)
      property_ids = properties["properties"].map{ |p| p["id"] }
      expect(property_ids).not_to include(p4.id) and expect(property_ids).to include(p3.id) and
      expect(property_ids).to include(p2.id) and expect(property_ids).to include(p1.id)
    end

    it "should return 401 if no user is logged in" do
      get :preview, params: {decision_aid_id: decision_aid.id}
      expect(response.status).to eq(401)
    end
  end

  describe "clone" do
    it "should clone the property if the user is creator", :user1 => true do
      clone_params = {name: "1234"}
      post :clone, params: {decision_aid_id: decision_aid.id, id: property.id}
      expect(response.status).to eq(200)
    end

    it "should clone the property if the user is the superadmin", :superuser => true do
      property.creator = user1
      property.save
      clone_params = {name: "1234"}
      post :clone, params: {decision_aid_id: decision_aid.id, id: property.id}
      expect(response.status).to eq(200)
    end

    it "should increase the property count on successful clone", :user1 => true do
      property.reload
      expect{post(:clone, params: {decision_aid_id: decision_aid.id, id: property.id})}
        .to change{decision_aid.reload.properties_count}.by(1)
    end

    it "should return 403 if the user is not the creator", :user1 => true do
      property.creator = user2
      property.save
      post :clone, params: {id: property.id, decision_aid_id: decision_aid.id}
      expect(response.status).to eq(403)
    end

    it "should return 401 if no user is logged in" do
      post :clone, params: {id: property.id, decision_aid_id: decision_aid.id}
      expect(response.status).to eq(401)
    end
  end

  describe "clone_order" do
    it "should change the property order if user has permission", :user1 => true do
      p1, p2 = create(:property, decision_aid_id: decision_aid.id), 
               create(:property, decision_aid_id: decision_aid.id)
      property_params = {property_order: 1}
      expect(p2.property_order).to eq(2)
      put :update_order, params: {property: property_params, decision_aid_id: decision_aid.id, id: p2.id}
      expect(p2.reload.property_order).to eq(1)
    end

    it "should return 401 if no user is logged in" do
      o1 = create(:property, decision_aid_id: decision_aid.id)
      property_params = {property_order: 1}
      put :update_order, params: {property: property_params, decision_aid_id: decision_aid.id, id: o1.id}
      expect(response.status).to eq(401)
    end
  end
end