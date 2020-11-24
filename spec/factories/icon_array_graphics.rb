# == Schema Information
#
# Table name: icon_array_graphics
#
#  id                  :integer          not null, primary key
#  selected_index      :string
#  selected_index_type :integer
#  num_per_row         :integer
#

FactoryGirl.define do
  factory :icon_array_graphic do
    title "icon array chart"
    num_per_row 25

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
