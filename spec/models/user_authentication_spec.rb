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

require 'rails_helper'

RSpec.describe UserAuthentication, type: :model do
  
  describe "validations" do
    it "fails to validate if email is missing" do
      user_auth = build(:user_authentication)
      expect(user_auth.save).to eq false
      expect(user_auth.errors.messages).to have_key :email
    end

    it "fails to validate if token is missing" do
      user_auth = build(:user_authentication, email: "test_user@email.com", token: nil)
      expect(user_auth.save).to eq false
      expect(user_auth.errors.messages).to have_key :token
    end

    it "saves if all parameters are there" do
      user_auth = build(:user_authentication, email: "test_user@email.com")
      expect(user_auth.save).to eq true
    end
  end

  describe "validate_user_auth" do
    let (:user_auth) {create(:user_authentication, email: "test_email@email.com")}

    it "fails to validate if the user email does not match the authentication email" do
      user = build(:user, email: "test_email_nomatch@email.com")
      expect(user_auth.validate_user_auth(user)).to eq false
    end

    it "fails to validate if the user_auth was created more than 2 days ago" do
      user = build(:user, email: "test_email@email.com")
      user_auth.created_at = 5.days.ago
      expect(user_auth.validate_user_auth(user)).to eq false
    end

    it "validates if email matches and user_auth was created less than 2 days ago" do
      user = build(:user, email: "test_email@email.com")
      expect(user_auth.validate_user_auth(user)).to eq true
    end
  end
end
