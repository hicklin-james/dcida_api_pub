# == Schema Information
#
# Table name: graphic_data
#
#  id                                   :integer          not null, primary key
#  graphic_id                           :integer
#  value                                :string
#  label                                :string
#  color                                :string
#  graphic_data_order                   :integer
#  sub_value                            :string
#  value_type                           :integer
#  sub_value_type                       :integer
#  animated_icon_array_graphic_stage_id :integer
#

require 'rails_helper'

RSpec.describe GraphicDatum, type: :model do
  let (:decision_aid) { create(:basic_decision_aid) }
  let (:graphic) { create(:horizontal_bar_chart_graphic, decision_aid_id: decision_aid.id) }

  describe "validations" do
    it "should fail to save if decision_aid_id is missing" do
      gd = build(:graphic_datum, value: nil, label: "test", value_type: 0, graphic_data_order: graphic.graphic_data.count + 1, graphic: graphic)
      expect(gd.save).to be false
      expect(gd.errors.messages).to have_key :value
    end

    it "should fail to save if value_type is missing" do
      gd = build(:graphic_datum, value: 25, label: "test", value_type: nil, graphic_data_order: graphic.graphic_data.count + 1, graphic: graphic)
      expect(gd.save).to be false
      expect(gd.errors.messages).to have_key :value_type
    end

    it "should fail to save if graphic_data_order is missing" do
      gd = build(:graphic_datum, value: 25, label: "test", value_type: 0, graphic_data_order: nil, graphic: graphic)
      expect(gd.save).to be false
      expect(gd.errors.messages).to have_key :graphic_data_order
    end

    it "should fail to save if graphic is missing" do
      gd = build(:graphic_datum, value: 25, label: "test", value_type: 0, graphic_data_order: graphic.graphic_data.count + 1, graphic: nil)
      expect(gd.save).to be false
      expect(gd.errors.messages).to have_key :graphic_or_stage
    end

    it "should save if graphic and all other attributes are set" do
      gd = build(:graphic_datum, value: 25, label: "test", value_type: 0, graphic_data_order: graphic.graphic_data.count + 1, graphic: graphic)
      expect(gd.save).to be true
    end
  end
end
