require "rails_helper"

RSpec.describe Api::UserAuthenticationsController, :type => :controller do

  let(:user1) { create(:user) }
  let(:token1) { double :acceptable? => true, :resource_owner_id => user1.id }

  let(:superuser) { create(:superuser) }
  let(:token3) { double :acceptable? => true, :resource_owner_id => superuser.id }

  before(:each, user1: true) do
    User.current_user = user1
    allow(controller).to receive(:doorkeeper_token) {token1}
  end

  before(:each, :superuser) do
    User.current_user = superuser
    allow(controller).to receive(:doorkeeper_token) {token3}
  end

  describe "create" do
    it "should fail to create if no user signed in" do
      user_auth_params = FactoryGirl.attributes_for(:user_authentication, email: "test_user@email.com")
      post :create, params: {user_authentication: user_auth_params}
      expect(response.status).to eq(401)
    end

    it "should fail to create if user requesting user_auth is not a superuser", :user1 => true do
      user_auth_params = FactoryGirl.attributes_for(:user_authentication, email: "test_user@email.com")
      post :create, params: {user_authentication: user_auth_params}
      expect(response.status).to eq(403)
    end

    it "should create if user is superuser", :superuser => true do
      user_auth_params = FactoryGirl.attributes_for(:user_authentication, email: "test_user@email.com")
      post :create, params: {user_authentication: user_auth_params}
      expect(response.status).to eq(200)
    end

    it "should send an invite email if request successful", :superuser => true, sidekiq: :inline do
      user_auth_params = FactoryGirl.attributes_for(:user_authentication, email: "test_user@email.com")
      request.headers["Origin"] = "http://dcida.com"
      expect{post :create, params: {user_authentication: user_auth_params}}.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(response.status).to eq(200)
    end
  end

end