# == Schema Information
#
# Table name: latent_class_options
#
#  id              :integer          not null, primary key
#  latent_class_id :integer
#  option_id       :integer
#  weight          :float
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

FactoryGirl.define do
  factory :latent_class_option do
    weight 10
  end
end
