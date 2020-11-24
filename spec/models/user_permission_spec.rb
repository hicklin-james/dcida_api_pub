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

require 'rails_helper'

RSpec.describe UserPermission, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
