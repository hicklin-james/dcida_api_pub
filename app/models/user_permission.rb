# == Schema Information
#
# Table name: user_permissions
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  decision_aid_id  :integer
#  permission_value :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class UserPermission < ApplicationRecord
  validates :user_id, :decision_aid_id, :permission_value, presence: true
  belongs_to :user
  belongs_to :decision_aid

  # DO NOT REMOVE OR CHANGE EXISTING KEY NAMES - methods are generated automatically based on key names and used in policies
  enum permission_value: { edit: 0, view: 1, remove: 2 }
end
