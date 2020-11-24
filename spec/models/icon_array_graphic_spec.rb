# == Schema Information
#
# Table name: icon_array_graphics
#
#  id                  :integer          not null, primary key
#  selected_index      :string
#  selected_index_type :integer
#  num_per_row         :integer
#

require 'rails_helper'

RSpec.describe IconArrayGraphic, type: :model do
  let (:decision_aid) { create(:basic_decision_aid, slug: "test_decision_aid") }

  describe "validations" do
    it "fails to save if the decision_aid_id is missing" do
      g = build(:icon_array_graphic)
      expect(g.save).to be false
      expect(g.errors.messages).to have_key :decision_aid_id
    end

    it "fails to save if the num_per_row is missing" do
      g = build(:icon_array_graphic, num_per_row: nil)
      expect(g.save).to be false
      expect(g.errors.messages).to have_key :num_per_row
    end

    it "fails to save if graphic_data is empty" do
      g = build(:icon_array_graphic, decision_aid_id: decision_aid.id)
      expect(g.save).to be false
      expect(g.errors.messages).to have_key :graphic_data
    end
  end

  describe "methods" do
    describe ".graphic_to_html" do
      let (:g) { create(:icon_array_graphic, decision_aid_id: decision_aid.id) }
      
      it "should only include sa-selected-index if the chart has a selected_index" do
        expect(/sa-selected-index/).not_to match(g.graphic_to_html)
        g.selected_index = 0
        expect(/sa-selected-index/).to match(g.graphic_to_html)
      end

      it "should include sa-num-per-row" do
        expect(/sa-num-per-row/).to match(g.graphic_to_html)
      end

      it "should include sd-icon-array" do
        expect(/sd-icon-array/).to match(g.graphic_to_html)
      end

      it "should include sa-data" do
        expect(/sa-data/).to match(g.graphic_to_html)
      end
    end
  end
end

