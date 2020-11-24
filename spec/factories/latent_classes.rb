# == Schema Information
#
# Table name: latent_classes
#
#  id                 :integer          not null, primary key
#  decision_aid_id    :integer
#  class_order        :integer
#  created_by_user_id :integer
#  updated_by_user_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

FactoryGirl.define do
  factory :latent_class do
    
  end
end
