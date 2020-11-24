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

class User < ApplicationRecord

  has_secure_password validations: false
  has_many :media_files, dependent: :destroy
  has_many :accordions, dependent: :destroy
  has_many :user_permissions, dependent: :destroy
  validates :first_name, :last_name, :presence => true
  validates :email, uniqueness: true, presence: true
  validates :password, presence: true, on: :create
  validates :password, confirmation: true
  validate :terms_have_been_accepted

  validates_presence_of :password_confirmation, :if => lambda {|user| user.password_digest_changed? }
  #attr_accessor :password_confirmation

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def self.current_user
    RequestStore.store[:current_user]
  end

  def self.current_user=(user)
    RequestStore.store[:current_user] = user
  end

  private

  def terms_have_been_accepted
    if !self.terms_accepted
      errors.add(:terms_and_conditions, "must be accepted")
    end
  end
end
