# == Schema Information
#
# Table name: latent_class_properties
#
#  id              :integer          not null, primary key
#  latent_class_id :integer
#  property_id     :integer
#  weight          :float
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

FactoryGirl.define do
  factory :latent_class_property do
    weight 10
  end
end
