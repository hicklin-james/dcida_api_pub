require "rails_helper"

RSpec.describe Api::OptionPropertiesController, :type => :controller do

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
  let (:option) { create(:option, decision_aid_id: decision_aid.id, sub_decision_id: decision_aid.sub_decisions.first.id) }
  let (:property) { create(:property, decision_aid_id: decision_aid.id) }
  let (:option_property) { create(:option_property, decision_aid_id: decision_aid.id, option_id: option.id, property_id: property.id) }

  describe "create" do
    it "should create if a user is logged in", :user1 => true do
      new_option_property_attrs = FactoryGirl.attributes_for(:option_property, option_id: option.id, property_id: property.id)
      post :create, params: {decision_aid_id: decision_aid.id, option_property: new_option_property_attrs}
      expect(response.status).to eq(200)
    end

    it "should not create if a user is not logged in" do
      new_option_property_attrs = FactoryGirl.attributes_for(:option_property)
      post :create, params: {decision_aid_id: decision_aid.id, option_property: new_option_property_attrs}
      expect(response.status).to eq(401)
    end
  end

  describe "show" do
    it "should render the option_property if the user is creator", :user1 => true do
      get :show, params: {decision_aid_id: decision_aid.id, id: option_property.id}
      expect(response.status).to eq(200)
    end

    it "should render the option_property if the user is the superadmin", :superuser => true do
      option_property.creator = user1
      option_property.save
      get :show, params: {decision_aid_id: decision_aid.id, id: option_property.id}
      expect(response.status).to eq(200)
    end

    it "should return 403 if the user is not the creator", :user1 => true do
      option_property.creator = user2
      option_property.save
      get :show, params: {decision_aid_id: decision_aid.id, id: option_property.id}
      expect(response.status).to eq(403)
    end

    it "should return 401 if no user is logged in" do
      get :show, params: {decision_aid_id: decision_aid.id, id: option_property.id}
      expect(response.status).to eq(401)
    end
  end

  describe "update" do
    it "should update the option_property if the user is creator", :user1 => true do
      update_params = {name: "1234"}
      put :update, params: {option_property: update_params, decision_aid_id: decision_aid.id, id: option_property.id}
      expect(response.status).to eq(200)
    end

    it "should update the option_property if the user is the superadmin", :superuser => true do
      option_property.creator = user1
      option_property.save
      update_params = {name: "1234"}
      put :update, params: {decision_aid_id: decision_aid.id, id: option_property.id, option_property: update_params}
      expect(response.status).to eq(200)
    end

    it "should return 403 if the user is not the creator", :user1 => true do
      option_property.creator = user2
      option_property.save
      put :update, params: {id: option_property.id, decision_aid_id: decision_aid.id}
      expect(response.status).to eq(403)
    end

    it "should return 401 if no user is logged in" do
      put :update, params: {id: option_property.id, decision_aid_id: decision_aid.id}
      expect(response.status).to eq(401)
    end
  end

  describe "destroy" do
    it "should destroy the option_property if the user is creator", :user1 => true do
      destroy_params = {name: "1234"}
      put :destroy, params: {option_property: destroy_params, decision_aid_id: decision_aid.id, id: option_property.id}
      expect(response.status).to eq(200)
    end

    it "should destroy the option_property if the user is the superadmin", :superuser => true do
      option_property.creator = user1
      option_property.save
      destroy_params = {name: "1234"}
      put :destroy, params: {decision_aid_id: decision_aid.id, id: option_property.id, option_property: destroy_params}
      expect(response.status).to eq(200)
    end

    it "should return 403 if the user is not the creator", :user1 => true do
      option_property.creator = user2
      option_property.save
      put :destroy, params: {id: option_property.id, decision_aid_id: decision_aid.id}
      expect(response.status).to eq(403)
    end

    it "should return 401 if no user is logged in" do
      put :destroy, params: {id: option_property.id, decision_aid_id: decision_aid.id}
      expect(response.status).to eq(401)
    end
  end

  describe "update_bulk" do
    let (:op1) { create(:option_property, decision_aid_id: decision_aid.id, option_id: option.id, property_id: property.id) }
    let (:o2) { create(:option, decision_aid_id: decision_aid.id, sub_decision_id: decision_aid.sub_decisions.first.id) }
    let (:op2) { create(:option_property, decision_aid_id: decision_aid.id, option_id: o2.id, property_id: property.id) }
    
    it "should return 403 if user isn't creator of an option property", user1: true do
      op1.creator = user2
      op1.save
      post :update_bulk, params: {decision_aid_id: decision_aid.id, option_properties: [op1.attributes, op2.attributes]}
      expect(response.status).to eq 403
    end

    it "should return 422 if a non-existant id is in the params", user1: true do
      bogus_op = {id: 0}
      post :update_bulk, params: {decision_aid_id: decision_aid.id, option_properties: [op1.attributes, bogus_op]}
      expect(response.status).to eq 422
    end

    it "should return 200 if all are new", user1: true do
      op1 = FactoryGirl.attributes_for(:option_property, decision_aid_id: decision_aid.id, option_id: option.id, property_id: property.id)
      op2 = FactoryGirl.attributes_for(:option_property, decision_aid_id: decision_aid.id, option_id: o2.id, property_id: property.id)
      post :update_bulk, params: {decision_aid_id: decision_aid.id, option_properties: [op1, op2]}
      expect(response.status).to eq 200
    end

    it "should return 200 if all are updated", user1: true do
      post :update_bulk, params: {decision_aid_id: decision_aid.id, option_properties: [op1.attributes, op2.attributes]}
      expect(response.status).to eq 200
    end

    it "should return 200 if user is superadmin", superuser: true do
      post :update_bulk, params: {decision_aid_id: decision_aid.id, option_properties: [op1.attributes, op2.attributes]}
      expect(response.status).to eq 200
    end

    it "should return 200 if some are new and some are updated", user1: true do
      op1 = FactoryGirl.attributes_for(:option_property, decision_aid_id: decision_aid.id, option_id: option.id, property_id: property.id)
      post :update_bulk, params: {decision_aid_id: decision_aid.id, option_properties: [op1, op2.attributes]}
      expect(response.status).to eq 200
    end
  end

  describe "index" do
    it "should show option_properties in decision aid", :user1 => true do
      o1, o2, o3, o4 = create(:option, decision_aid_id: decision_aid.id, sub_decision_id: decision_aid.sub_decisions.first.id), 
                       create(:option, decision_aid_id: decision_aid.id, sub_decision_id: decision_aid.sub_decisions.first.id), 
                       create(:option, decision_aid_id: decision_aid.id, sub_decision_id: decision_aid.sub_decisions.first.id), 
                       create(:option, decision_aid_id: decision_aid.id, sub_decision_id: decision_aid.sub_decisions.first.id)
      p1 = create(:property, decision_aid_id: decision_aid.id)
      op1, op2, op3, op4 = create(:option_property, decision_aid_id: decision_aid.id, option_id: o1.id, property_id: p1.id), 
                           create(:option_property, decision_aid_id: decision_aid.id, option_id: o2.id, property_id: p1.id), 
                           create(:option_property, decision_aid_id: decision_aid.id, option_id: o3.id, property_id: p1.id),
                           create(:option_property, decision_aid_id: decision_aid.id, option_id: o4.id, property_id: p1.id)
      get :index, params: {decision_aid_id: decision_aid.id}
      option_properties = JSON.parse(response.body)
      option_property_ids = option_properties["option_properties"].map{ |o| o["id"] }
      expect(option_property_ids).to include(op4.id) and expect(option_property_ids).to include(op3.id) and
      expect(option_property_ids).to include(op2.id) and expect(option_property_ids).to include(op1.id)
    end

    it "should return 401 if no user is logged in" do
      get :index, params: {decision_aid_id: decision_aid.id}
      expect(response.status).to eq(401)
    end
  end

  describe "preview" do
    it "should show option_properties in decision aid", :user1 => true do
      o1, o2, o3, o4 = create(:option, decision_aid_id: decision_aid.id, sub_decision_id: decision_aid.sub_decisions.first.id), create(:option, decision_aid_id: decision_aid.id, sub_decision_id: decision_aid.sub_decisions.first.id), create(:option, decision_aid_id: decision_aid.id, sub_decision_id: decision_aid.sub_decisions.first.id), create(:option, decision_aid_id: decision_aid.id, sub_decision_id: decision_aid.sub_decisions.first.id)
      p1 = create(:property, decision_aid_id: decision_aid.id)
      op1, op2, op3, op4 = create(:option_property, decision_aid_id: decision_aid.id, option_id: o1.id, property_id: p1.id), 
                           create(:option_property, decision_aid_id: decision_aid.id, option_id: o2.id, property_id: p1.id), 
                           create(:option_property, decision_aid_id: decision_aid.id, option_id: o3.id, property_id: p1.id),
                           create(:option_property, decision_aid_id: decision_aid.id, option_id: o4.id, property_id: p1.id)
      get :preview, params: {decision_aid_id: decision_aid.id}
      option_properties = JSON.parse(response.body)
      option_property_ids = option_properties["option_properties"].map{ |o| o["id"] }
      expect(option_property_ids).to include(op4.id) and expect(option_property_ids).to include(op3.id) and
      expect(option_property_ids).to include(op2.id) and expect(option_property_ids).to include(op1.id)
    end

    it "should return 401 if no user is logged in" do
      get :preview, params: {decision_aid_id: decision_aid.id}
      expect(response.status).to eq(401)
    end
  end
end