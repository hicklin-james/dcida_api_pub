require "rails_helper"

RSpec.describe Api::DecisionAidUserOptionPropertiesController, :type => :controller do
  let (:decision_aid) { create(:full_decision_aid, slug: "test_decision_aid") }
  let (:decision_aid_user) { create(:decision_aid_user, decision_aid_id: decision_aid.id) }

  before do
    DecisionAidUserSession.create_or_update_user_session(decision_aid_user.id)
    request.headers.merge!("DECISION-AID-USER-ID" => decision_aid_user.id)
  end

  describe "index" do
    def generate_user_option_properties(da, dau)
      option_props = []
      da.option_properties.each do |op|
        option_props.push create(:decision_aid_user_option_property, option_property_id: op.id, property_id: op.property_id, option_id: op.option_id, decision_aid_user: dau)
      end
      option_props
    end

    before do
      generate_user_option_properties(decision_aid, decision_aid_user)
    end

    it "should return decision aid user option properties" do
      get :index, params: {decision_aid_user_id: decision_aid_user.id}
      ops = JSON.parse(response.body)["decision_aid_user_option_properties"]
      expect(ops.length).to eq(decision_aid.option_properties.length)
      expect(ops.length).to be > 0
    end

    it "should only return the option properties associated with the current decision aid user" do
      da2 = create(:full_decision_aid, slug: "test_decision_aid_2")
      dau2 = create(:decision_aid_user, decision_aid_id: decision_aid.id)
      da2_ops = generate_user_option_properties(da2, dau2)
      get :index, params: {decision_aid_user_id: decision_aid_user.id}
      ops = JSON.parse(response.body)["decision_aid_user_option_properties"]
      expect(da2_ops.length).to eq decision_aid.option_properties.length
      expect(da2_ops.length).to be > 0
      new_op_ids = da2_ops.map {|p| p.id}
      ops.each do |p|
        expect(new_op_ids).not_to include(p["id"].to_i)
      end
    end
  end

  describe "update_user_option_properties" do
    def user_option_property_atts(da, dau)
      option_props = []
      da.option_properties.each do |op|
        option_props.push FactoryGirl.attributes_for(:decision_aid_user_option_property, option_property_id: op.id, property_id: op.property_id, option_id: op.option_id, decision_aid_user_id: dau.id)
      end
      option_props
    end

    def user_option_properties(da, dau)
      option_props = []
      da.option_properties.each do |op|
        option_props.push create(:decision_aid_user_option_property, option_property_id: op.id, property_id: op.property_id, option_id: op.option_id, decision_aid_user_id: dau.id)
      end
      option_props
    end

    it "should create new user option properties if params don't have ids present" do
      op_atts = user_option_property_atts(decision_aid, decision_aid_user)
      expect{post(:update_user_option_properties, params: {decision_aid_user_id: decision_aid_user.id, decision_aid_user_option_properties: {option_properties: op_atts}})}
            .to change{DecisionAidUserOptionProperty.count}.by(op_atts.length)
      expect(response.status).to eq(200)
    end

    it "should update user option properties if params have ids present" do
      ops = user_option_properties(decision_aid, decision_aid_user)
      expect{post(:update_user_option_properties, params: {decision_aid_user_id: decision_aid_user.id, decision_aid_user_option_properties: {option_properties: ops.as_json}})}
            .not_to change{DecisionAidUserOptionProperty.count}
      expect(response.status).to eq(200)
    end

    it "should create new ones and update existing ones in the same request" do
      op_attributes = user_option_property_atts(decision_aid, decision_aid_user)
      n = 0
      params = []
      while n < op_attributes.length / 2
        r = create(:decision_aid_user_option_property, op_attributes[n])
        params.push r.as_json
        n += 1
      end
      new_count = 0
      while n < op_attributes.length
        params.push op_attributes[n]
        n += 1
        new_count += 1
      end
      expect{post(:update_user_option_properties, params: {decision_aid_user_id: decision_aid_user.id, decision_aid_user_option_properties: {option_properties: params}})}
            .to change{DecisionAidUserOptionProperty.count}.by(new_count)
      body = JSON.parse(response.body)
      expect(body.has_key?("decision_aid_user_option_properties")).to be true
      expect(body["decision_aid_user_option_properties"].kind_of?(Array)).to be true
      expect(body["decision_aid_user_option_properties"].length).to eq(params.length)
    end

    it "should return an error if there are no user option properties in the request" do
      post :update_user_option_properties, params: {decision_aid_user_id: decision_aid_user.id}
      expect(response.status).to eq(400)
      body = JSON.parse(response.body)
      expect(body.has_key?("errors")).to eq(true)
      expect(body["errors"].has_key?("decision_aid_user_option_properties")).to eq(true)
      expect(body["errors"]["decision_aid_user_option_properties"]).to include({"Exceptions::MissingParams" => 'ParamMissing'})
    end

    it "should raise an error if an invalid id is passed in the params" do
      ops = user_option_properties(decision_aid, decision_aid_user)
      ops.first.id = 0
      post(:update_user_option_properties, params: {decision_aid_user_id: decision_aid_user.id, decision_aid_user_option_properties: {option_properties: ops.as_json}})
      expect(response.status).to eq(400)
      body = JSON.parse(response.body)
      expect(body["errors"].has_key?("decision_aid_user_option_properties")).to eq(true)
      expect(body["errors"]["decision_aid_user_option_properties"]).to include({"Exceptions::InvalidParams" => 'InvalidId'})
    end
  end
end