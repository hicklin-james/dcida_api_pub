# == Schema Information
#
# Table name: horizontal_bar_chart_graphics
#
#  id                  :integer          not null, primary key
#  selected_index      :string
#  selected_index_type :integer
#  max_value           :string
#

FactoryGirl.define do
  factory :horizontal_bar_chart_graphic do
    title "horizontal bar chart"
    max_value 100

    transient do
      data_count 5
    end

    before(:create) do |chart, evaluator|
      graphic_data_attrs = []
      0.upto(evaluator.data_count-1) do |i|
        graphic_data_attrs.push FactoryGirl.attributes_for(:graphic_datum, graphic_data_order: i+1)
      end
      chart.graphic_data_attributes = graphic_data_attrs
    end
  end
end
