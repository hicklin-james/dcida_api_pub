# == Schema Information
#
# Table name: horizontal_bar_chart_graphics
#
#  id                  :integer          not null, primary key
#  selected_index      :string
#  selected_index_type :integer
#  max_value           :string
#

require 'rails_helper'

RSpec.describe HorizontalBarChartGraphic, type: :model do
  let (:decision_aid) { create(:basic_decision_aid, slug: "test_decision_aid") }

  describe "validations" do
    it "fails to save if the decision_aid_id is missing" do
      g = build(:horizontal_bar_chart_graphic)
      expect(g.save).to be false
      expect(g.errors.messages).to have_key :decision_aid_id
    end

    it "fails to save if the max_value is missing" do
      g = build(:horizontal_bar_chart_graphic, max_value: nil)
      expect(g.save).to be false
      expect(g.errors.messages).to have_key :max_value
    end

    it "fails to save if graphic_data is empty" do
      g = build(:horizontal_bar_chart_graphic, decision_aid_id: decision_aid.id)
      expect(g.save).to be false
      expect(g.errors.messages).to have_key :graphic_data
    end
  end

  describe "methods" do
    describe ".graphic_to_html" do
      let (:g) { create(:horizontal_bar_chart_graphic, decision_aid_id: decision_aid.id) }
      
      it "should only include sa-selected-index if the chart has a selected_index" do
        expect(/sa-selected-index/).not_to match(g.graphic_to_html)
        g.selected_index = 0
        expect(/sa-selected-index/).to match(g.graphic_to_html)
      end

      it "should include sa-max-value" do
        expect(/sa-max-value/).to match(g.graphic_to_html)
      end

      it "should include sd-horizontal-bar-chart" do
        expect(/sd-horizontal-bar-chart/).to match(g.graphic_to_html)
      end

      it "should include sa-data" do
        expect(/sa-data/).to match(g.graphic_to_html)
      end
    end
  end
end
