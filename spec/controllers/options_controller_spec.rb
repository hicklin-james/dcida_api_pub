require "rails_helper"

RSpec.describe Api::OptionsController, :type => :controller do

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

  describe "create" do
    it "should create if a user is logged in", :user1 => true do
      new_option_attrs = FactoryGirl.attributes_for(:option, sub_decision_id: decision_aid.sub_decisions.first.id)
      post :create, params: {decision_aid_id: decision_aid.id, option: new_option_attrs}
      expect(response.status).to eq(200)
    end

    it "should not create if a user is not logged in" do
      new_option_attrs = FactoryGirl.attributes_for(:option)
      post :create, params: {decision_aid_id: decision_aid.id, option: new_option_attrs}
      expect(response.status).to eq(401)
    end
  end

  describe "show" do
    it "should render the option if the user is creator", :user1 => true do
      get :show, params: {decision_aid_id: decision_aid.id, id: option.id}
      expect(response.status).to eq(200)
    end

    it "should render the option if the user is the superadmin", :superuser => true do
      option.creator = user1
      option.save
      get :show, params: {decision_aid_id: decision_aid.id, id: option.id}
      expect(response.status).to eq(200)
    end

    it "should return 403 if the user is not the creator", :user1 => true do
      option.creator = user2
      option.save
      get :show, params: {decision_aid_id: decision_aid.id, id: option.id}
      expect(response.status).to eq(403)
    end

    it "should return 401 if no user is logged in" do
      get :show, params: {decision_aid_id: decision_aid.id, id: option.id}
      expect(response.status).to eq(401)
    end
  end

  describe "update" do
    it "should update the option if the user is creator", :user1 => true do
      update_params = {name: "1234"}
      put :update, params: {option: update_params, decision_aid_id: decision_aid.id, id: option.id}
      expect(response.status).to eq(200)
    end

    it "should update the option if the user is the superadmin", :superuser => true do
      option.creator = user1
      option.save
      update_params = {name: "1234"}
      put :update, params: {decision_aid_id: decision_aid.id, id: option.id, option: update_params}
      expect(response.status).to eq(200)
    end

    it "should return 403 if the user is not the creator", :user1 => true do
      option.creator = user2
      option.save
      put :update, params: {id: option.id, decision_aid_id: decision_aid.id}
      expect(response.status).to eq(403)
    end

    it "should return 401 if no user is logged in" do
      put :update, params: {id: option.id, decision_aid_id: decision_aid.id}
      expect(response.status).to eq(401)
    end
  end

  describe "destroy" do
    it "should destroy the option if the user is creator", :user1 => true do
      destroy_params = {name: "1234"}
      put :destroy,params: {option: destroy_params, decision_aid_id: decision_aid.id, id: option.id}
      expect(response.status).to eq(200)
    end

    it "should destroy the option if the user is the superadmin", :superuser => true do
      option.creator = user1
      option.save
      destroy_params = {name: "1234"}
      put :destroy,params: {decision_aid_id: decision_aid.id, id: option.id, option: destroy_params}
      expect(response.status).to eq(200)
    end

    it "should return 403 if the user is not the creator", :user1 => true do
      option.creator = user2
      option.save
      put :destroy,params: {id: option.id, decision_aid_id: decision_aid.id}
      expect(response.status).to eq(403)
    end

    it "should return 401 if no user is logged in" do
      put :destroy,params: {id: option.id, decision_aid_id: decision_aid.id}
      expect(response.status).to eq(401)
    end
  end

  describe "index" do
    it "should only show options in decision aid", :user1 => true do
      da2 = create(:basic_decision_aid)
      o1, o2, o3, o4 = create(:option, decision_aid_id: decision_aid.id, sub_decision_id: decision_aid.sub_decisions.first.id), 
                       create(:option, decision_aid_id: decision_aid.id, sub_decision_id: decision_aid.sub_decisions.first.id), 
                       create(:option, decision_aid_id: decision_aid.id, sub_decision_id: decision_aid.sub_decisions.first.id), 
                       create(:option, decision_aid_id: da2.id, sub_decision_id: da2.sub_decisions.first.id)
      get :index, params: {decision_aid_id: decision_aid.id}
      options = JSON.parse(response.body)
      option_ids = options["options"].map{ |o| o["id"] }
      expect(option_ids).not_to include(o4.id) and expect(option_ids).to include(o3.id) and
      expect(option_ids).to include(o2.id) and expect(option_ids).to include(o1.id)
    end

    it "should return 401 if no user is logged in" do
      get :index, params: {decision_aid_id: decision_aid.id}
      expect(response.status).to eq(401)
    end
  end

  describe "preview" do
    it "should only show options in the decision aid", :user1 => true do
      da2 = create(:basic_decision_aid)
      o1, o2, o3, o4 = create(:option, decision_aid_id: decision_aid.id, sub_decision_id: decision_aid.sub_decisions.first.id), 
                       create(:option, decision_aid_id: decision_aid.id, sub_decision_id: decision_aid.sub_decisions.first.id), 
                       create(:option, decision_aid_id: decision_aid.id, sub_decision_id: decision_aid.sub_decisions.first.id), 
                       create(:option, decision_aid_id: da2.id, sub_decision_id: da2.sub_decisions.first.id)
      get :preview, params: {decision_aid_id: decision_aid.id}
      options = JSON.parse(response.body)
      option_ids = options["options"].map{ |o| o["id"] }
      expect(option_ids).not_to include(o4.id) and expect(option_ids).to include(o3.id) and
      expect(option_ids).to include(o2.id) and expect(option_ids).to include(o1.id)
    end

    it "should return 401 if no user is logged in" do
      get :preview, params: {decision_aid_id: decision_aid.id}
      expect(response.status).to eq(401)
    end
  end

  describe "update_order" do
    it "should change the option order if user has permission", :user1 => true do
      o1, o2 = create(:option, decision_aid_id: decision_aid.id, sub_decision_id: decision_aid.sub_decisions.first.id), 
               create(:option, decision_aid_id: decision_aid.id, sub_decision_id: decision_aid.sub_decisions.first.id)
      option_params = {option_order: 1}
      expect(o2.option_order).to eq(2)
      put :update_order, params: {option: option_params, decision_aid_id: decision_aid.id, id: o2.id}
      expect(o2.reload.option_order).to eq(1)
    end

    it "should return 401 if no user is logged in" do
      o1 = create(:option, decision_aid_id: decision_aid.id, sub_decision_id: decision_aid.sub_decisions.first.id)
      option_params = {option_order: 1}
      put :update_order, params: {option: option_params, decision_aid_id: decision_aid.id, id: o1.id}
      expect(response.status).to eq(401)
    end
  end

  describe "clone" do
    it "should render the cloned option if the user is creator", :user1 => true do
      post :clone, params: {decision_aid_id: decision_aid.id, id: option.id}
      expect(response.status).to eq(200)
    end

    it "should render the cloned option if the user is the superadmin", :superuser => true do
      option.creator = user1
      option.save
      post :clone, params: {decision_aid_id: decision_aid.id, id: option.id}
      expect(response.status).to eq(200)
    end

    it "should increase the option count on successful clone", :user1 => true do
      option.reload
      expect{post(:clone, params: {decision_aid_id: decision_aid.id, id: option.id})}
        .to change{decision_aid.reload.options_count}.by(1)
    end

    it "should return 403 if the user is not the creator", :user1 => true do
      option.creator = user2
      option.save
      post :clone, params: {decision_aid_id: decision_aid.id, id: option.id}
      expect(response.status).to eq(403)
    end

    it "should return 401 if no user is logged in" do
      post :clone, params: {decision_aid_id: decision_aid.id, id: option.id}
      expect(response.status).to eq(401)
    end
  end
end