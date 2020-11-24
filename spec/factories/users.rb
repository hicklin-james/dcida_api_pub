# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  email           :string           default(""), not null
#  first_name      :string
#  last_name       :string
#  password_digest :string           not null
#  is_superadmin   :boolean          default(FALSE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  last_logged_in  :datetime
#  terms_accepted  :boolean
#

FactoryGirl.define do
  sequence :email do |n|
    "user_#{n}@hotmail.com"
  end

  factory :user do
    email
    password 'password'
    password_confirmation 'password'
    terms_accepted true
    first_name "Joe"
    last_name "Fake"

    factory :superuser do
      is_superadmin true
    end
  end
end
