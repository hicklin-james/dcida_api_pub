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

FactoryGirl.define do
  factory :graphic_datum do
    value_type 0 # decimal
    value 10
    label "graphic_datum_point"
    color "green"
  end
end
