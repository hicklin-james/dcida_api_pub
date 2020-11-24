require "rails_helper"

RSpec.describe Api::DecisionAidUserPropertiesController, :type => :controller do
  let (:decision_aid) { create(:full_decision_aid, slug: "test_decision_aid") }
  let (:decision_aid_user) { create(:decision_aid_user, decision_aid_id: decision_aid.id) }

  before do
    DecisionAidUserSession.create_or_update_user_session(decision_aid_user.id)
    request.headers.merge!("DECISION-AID-USER-ID" => decision_aid_user.id)
  end

  describe "index" do
    def generate_user_properties(da, dau)
      props = []
      da.properties.each do |prop|
        props.push create(:decision_aid_user_property, property_id: prop.id, decision_aid_user: dau)
      end
      props
    end

    before do
      generate_user_properties(decision_aid, decision_aid_user)
    end

    it "should return decision aid user properties" do
      get :index, params: {decision_aid_user_id: decision_aid_user.id}
      properties = JSON.parse(response.body)["decision_aid_user_properties"]
      expect(properties.length).to eq decision_aid.properties.length
      expect(properties.length).to be > 0
    end

    it "should only return the properties associated with the current decision aid user" do
      da2 = create(:full_decision_aid, slug: "test_decision_aid_2")
      dau2 = create(:decision_aid_user, decision_aid_id: decision_aid.id)
      da2_props = generate_user_properties(da2, dau2)
      get :index, params: {decision_aid_user_id: decision_aid_user.id}
      properties = JSON.parse(response.body)["decision_aid_user_properties"]
      expect(da2_props.length).to eq decision_aid.properties.length
      expect(da2_props.length).to be > 0
      new_prop_ids = da2_props.map {|p| p.id}
      properties.each do |p|
        expect(new_prop_ids).not_to include(p["id"].to_i)
      end
    end
  end

  describe "update_selections" do
    def user_property_attributes(da, dau)
      prop_attributes = []
      da.properties.each do |prop|
        prop_attributes.push FactoryGirl.attributes_for(:decision_aid_user_property, property_id: prop.id, decision_aid_user_id: dau.id)
      end
      prop_attributes
    end

    def user_properties(da, dau)
      props = []
      da.properties.each do |prop|
        props.push create(:decision_aid_user_property, property_id: prop.id, decision_aid_user_id: dau.id)
      end
      props
    end

    it "should return an error if there are no user properties in the request" do
      post :update_selections, params: {decision_aid_user_id: decision_aid_user.id}
      expect(response.status).to eq(400)
      body = JSON.parse(response.body)
      expect(body.has_key?("errors")).to eq(true)
      expect(body["errors"].has_key?("decision_aid_user_properties")).to eq(true)
      expect(body["errors"]["decision_aid_user_properties"]).to include({"Exceptions::MissingParams" => 'ParamMissing'})
    end

    it "should create new user properties if params don't have ids present" do
      property_atts = user_property_attributes(decision_aid, decision_aid_user)
      expect{post(:update_selections, params: {decision_aid_user_id: decision_aid_user.id, decision_aid_user_properties: {properties: property_atts}})}
            .to change{DecisionAidUserProperty.count}.by(property_atts.length)
      expect(response.status).to eq(200)
    end

    it "should update user properties if params have ids present" do
      props = user_properties(decision_aid, decision_aid_user)
      expect{post(:update_selections, params: {decision_aid_user_id: decision_aid_user.id, decision_aid_user_properties: {properties: props.as_json}})}
            .not_to change{DecisionAidUserProperty.count}
      expect(response.status).to eq(200)
    end

    it "should create new ones and update existing ones in the same request" do
      prop_attributes = user_property_attributes(decision_aid, decision_aid_user)
      n = 0
      params = []
      while n < prop_attributes.length / 2
        r = create(:decision_aid_user_property, prop_attributes[n])
        params.push r.as_json
        n += 1
      end
      new_count = 0
      while n < prop_attributes.length
        params.push prop_attributes[n]
        n += 1
        new_count += 1
      end
      expect{post(:update_selections, params: {decision_aid_user_id: decision_aid_user.id, decision_aid_user_properties: {properties: params}})}
            .to change{DecisionAidUserProperty.count}.by(new_count)
      body = JSON.parse(response.body)
      expect(body.has_key?("decision_aid_user_properties")).to be true
      expect(body["decision_aid_user_properties"].kind_of?(Array)).to be true
      expect(body["decision_aid_user_properties"].length).to eq(params.length)
    end

    it "should raise an error if there are some required params missing" do
      prop_atts = user_property_attributes(decision_aid, decision_aid_user)
      prop_atts.first[:property_id] = nil
      post(:update_selections, params: {decision_aid_user_id: decision_aid_user.id, decision_aid_user_properties: {properties: prop_atts}})
      body = JSON.parse(response.body)
      expect(body["errors"].has_key?("decision_aid_user_properties")).to eq(true)
      expect(body["errors"]["decision_aid_user_properties"].map{|v| v.keys}.flatten).to include("ActiveRecord::RecordInvalid")
    end
  end
end