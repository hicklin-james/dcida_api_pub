# == Schema Information
#
# Table name: user_authentications
#
#  id           :integer          not null, primary key
#  token        :string           not null
#  is_superuser :boolean          default(FALSE), not null
#  email        :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

FactoryGirl.define do
  factory :user_authentication do
    token "auth_token"
    is_superuser false
  end
end
