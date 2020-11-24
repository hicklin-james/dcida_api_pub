require "rails_helper"

RSpec.describe Api::IconsController, :type => :controller do
  
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
  let (:other_decision_aid) { create(:basic_decision_aid, slug: "other_decision_aid") }
  let (:icon) { create(:icon, decision_aid_id: decision_aid.id) }
  let (:icon2) { create(:icon, decision_aid_id: decision_aid.id) }

  describe "index" do
    it "should only show icons scoped to decision aid", :user1 => true do
      ic1, ic2, ic3, ic4 = create(:icon, decision_aid_id: decision_aid.id), create(:icon, decision_aid_id: decision_aid.id), 
        create(:icon, decision_aid_id: decision_aid.id), create(:icon, decision_aid_id: other_decision_aid.id)
      get :index, params: {decision_aid_id: decision_aid.id}
      body = JSON.parse(response.body)
      icon_ids = body["icons"].map{ |i| i["id"] }
      expect(icon_ids).not_to include(ic4.id)
      expect(icon_ids).to include(ic3.id)
      expect(icon_ids).to include(ic2.id)
      expect(icon_ids).to include(ic1.id)
    end

    it "should show all the icons if the logged in user is a superadmin", :superuser => true do
      ic1, ic2, ic3, ic4 = create(:icon, decision_aid_id: decision_aid.id), create(:icon, decision_aid_id: decision_aid.id), 
        create(:icon, decision_aid_id: decision_aid.id), create(:icon, decision_aid_id: decision_aid.id)
      ic1.creator, ic2.creator, ic3.creator, ic4.creator = user2, user2, user2, user2
      ic1.save and ic2.save and ic3.save and ic4.save
      get :index, params: {decision_aid_id: decision_aid.id}
      body = JSON.parse(response.body)
      icon_ids = body["icons"].map{ |ic| ic["id"] }
      expect(icon_ids).to include(ic4.id) and expect(icon_ids).to include(ic3.id) and
      expect(icon_ids).to include(ic2.id) and expect(icon_ids).to include(ic1.id)
    end

    it "should return 401 if no user is logged in" do
      get :index, params: {decision_aid_id: decision_aid.id}
      expect(response.status).to eq(401)
    end
  end

  describe "create" do
    it "should create if a user is logged in", :user1 => true do
      new_icon_attrs = FactoryGirl.attributes_for(:icon)
      post :create, params: {decision_aid_id: decision_aid.id, icon: new_icon_attrs}
      expect(response.status).to eq(200)
    end

    it "should not create and return 401 if a user is not logged in" do
      new_icon_attrs = FactoryGirl.attributes_for(:icon)
      post :create, params: {decision_aid_id: decision_aid.id, icon: new_icon_attrs}
      expect(response.status).to eq(401)
    end

    it "should create if user is superadmin", superuser: true do
      new_icon_attrs = FactoryGirl.attributes_for(:icon)
      post :create, params: {decision_aid_id: decision_aid.id, icon: new_icon_attrs}
      expect(response.status).to eq(200)
    end
  end

  describe "destroy" do 
    it "should destroy if user is creator", :user1 => true do
      put :destroy, params: {decision_aid_id: decision_aid.id, id: icon.id}
      expect(response.status).to eq(200)
    end

    it "should destroy if user is superadmin", superuser: true do
      icon.creator = user1
      icon.save
      put :destroy, params: {decision_aid_id: decision_aid.id, id: icon.id}
      expect(response.status).to eq(200)
    end

    it "should return 401 if user is not logged in" do
      put :destroy, params: {decision_aid_id: decision_aid.id, id: icon.id}
      expect(response.status).to eq(401)
    end

    it "should return 403 if user is not creator", user2: true do
      icon.creator = user1
      icon.save
      put :destroy, params: {decision_aid_id: decision_aid.id, id: icon.id}
      expect(response.status).to eq(403)
    end
  end

  describe "update_bulk" do
    it "should return 200 if user is creator", user1: true do
      icon_params = [{id: icon.id, url: "abc@def.com"}, {id: icon2.id, url: "ghi@jkl.com"}]
      post :update_bulk, params: {decision_aid_id: decision_aid.id, icons: icon_params}
      expect(response.status).to eq(200)
    end

    it "should return 200 if user is superadmin", superuser: true do
      icon.creator, icon2.creator = user1, user1
      icon.save && icon2.save
      icon_params = [{id: icon.id, url: "abc@def.com"}, {id: icon2.id, url: "ghi@jkl.com"}]
      post :update_bulk, params: {decision_aid_id: decision_aid.id, icons: icon_params}
      expect(response.status).to eq(200)
    end

    it "should return 401 if no user is logged in" do
      icon_params = [{id: icon.id, url: "abc@def.com"}, {id: icon2.id, url: "ghi@jkl.com"}]
      post :update_bulk, params: {decision_aid_id: decision_aid.id, icons: icon_params}
      expect(response.status).to eq(401)
    end

    it "should return 403 if user is not creator of all icons", user1: true do
      icon.creator, icon2.creator = user1, user2
      icon.save && icon2.save
      icon_params = [{id: icon.id, url: "abc@def.com"}, {id: icon2.id, url: "ghi@jkl.com"}]
      post :update_bulk, params: {decision_aid_id: decision_aid.id, icons: icon_params}
      expect(response.status).to eq(403)
    end
  end
end