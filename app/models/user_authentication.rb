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

class UserAuthentication < ApplicationRecord
  validates :token, presence: true
  validates :email, uniqueness: true, presence: true
  validates_inclusion_of :is_superuser, in: [true, false]

  def validate_user_auth(user)
    if user.email != self.email
      user.errors.add(:email, "Account email must match user authentication email")
      return false
    elsif (Time.now - self.created_at) > 2.days
      user.errors.add(:base, "Token expired.")
      self.destroy
      return false
    end
    return true
  end
end
