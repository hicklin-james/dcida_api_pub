require "rails_helper"

RSpec.describe Api::UsersController, :type => :controller do
  
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

  describe "current" do
    it "should return the current user", :user1 => true do
      get :current
      expect(response.status).to eq(200)
    end

    it "should return 401 if no user is logged in" do
      get :current
      expect(response.status).to eq(401)
    end
  end

  describe "index" do
    it "should only show the current user if the user isn't the superadmin", :user1 => true do
      u1, u2, u3, u4 = create(:user), create(:user), create(:user), create(:user)
      get :index
      body = JSON.parse(response.body)
      user_ids = body["users"].map{ |u| u["id"] }
      expect(user_ids.length).to eq 1
      expect(user_ids.first.to_i).to eq user1.id
    end

    it "should show all the users if the user is superadmin", :superuser => true do
      u1, u2, u3, u4 = create(:user), create(:user), create(:user), create(:user)
      get :index
      body = JSON.parse(response.body)
      user_ids = body["users"].map{ |u| u["id"] }
      expect(user_ids.length).to eq 5
    end

    it "should return 401 if no user is logged in" do
      get :index
      expect(response.status).to eq(401)
    end
  end

  describe "create_from_admin" do
    it "should create if the user is the superadmin", superuser: true do
      create_params = FactoryGirl.attributes_for(:user)
      ua = UserAuthentication.create(email: create_params[:email], token: "test_token")
      post :create_from_admin, params: {user: create_params, creation_token: "test_token"}
      #puts response.inspect
      expect(response.status).to eq(200)
    end


    it "should fail if the user is not a superadmin", user1: true do
      create_params = FactoryGirl.attributes_for(:user)
      post :create_from_admin, params: {user: create_params}
      expect(response.status).to eq(403)
    end

    it "should fail if no user is logged in" do
      create_params = FactoryGirl.attributes_for(:user)
      post :create_from_admin, params: {user: create_params}
      expect(response.status).to eq(401)
    end
  end

  describe "update" do
    it "should update if the user is the superadmin", superuser: true do
      update_params = {first_name: "Bob"}
      put :update, params: {id: user1.id, user: update_params}
      expect(response.status).to eq(200)
    end

    it "should update if the user is the current user", user1: true do
      update_params = {first_name: "Bob"}
      put :update, params: {id: user1.id, user: update_params}
      expect(response.status).to eq(200)
    end

    it "should fail if the user is not the current user", user2: true do
      update_params = {first_name: "Bob"}
      put :update, params: {id: user1.id, user: update_params}
      expect(response.status).to eq(403)
    end

    it "should fail if no user is logged in" do
      update_params = {first_name: "Bob"}
      put :update, params: {id: user1.id, user: update_params}
      expect(response.status).to eq(401)
    end
  end

  describe "destroy" do
    it "should destroy if the user is the superadmin", superuser: true do
      put :destroy, params: {id: user1.id}
      expect(response.status).to eq(200)
    end

    it "should fail if the user is not a superadmin", user2: true do
      put :destroy, params: {id: user1.id}
      expect(response.status).to eq(403)
    end

    it "should fail if no user is logged in" do
      put :destroy, params: {id: user1.id}
      expect(response.status).to eq(401)
    end
  end

  describe "show" do
    it "should render the user if the user is logged in user", :user1 => true do
      get :show, params: {id: user1.id}
      expect(response.status).to eq(200)
    end

    it "should render the user if the user is the superadmin", :superuser => true do
      get :show, params: {id: user1.id}
      expect(response.status).to eq(200)
    end

    it "should return 403 if the user is not the current user", :user1 => true do
      get :show, params: {id: user2.id}
      expect(response.status).to eq(403)
    end

    it "should return 401 if no user is logged in" do
      get :show, params: {id: user1.id}
      expect(response.status).to eq(401)
    end
  end

end