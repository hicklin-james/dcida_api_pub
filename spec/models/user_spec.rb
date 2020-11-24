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

require "rails_helper"

RSpec.describe User, :type => :model do

  describe "validations" do
    it "should fail to save if email is missing" do
      u = build(:user, email: nil)
      expect(u.save).to be false
      expect(u.errors.messages).to have_key :email
    end

    it "should fail to save if password is missing" do
      u = build(:user, password: nil)
      expect(u.save).to be false
      expect(u.errors.messages).to have_key :password
    end

    it "should fails to save if email isn't unique" do
      u1 = create(:user, email: "123@abc.com")
      u2 = build(:user, email: "123@abc.com")
      expect(u2.save).to be false
      expect(u2.errors.messages).to have_key :email
    end

    it "should save if all required attributes are there" do
      u = build(:user)
      expect(u.save).to be true
    end
  end
end
