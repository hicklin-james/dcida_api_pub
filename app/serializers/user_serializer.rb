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

class UserSerializer < ActiveModel::Serializer

  attributes :id,
    :email,
    :first_name,
    :last_name,
    :is_superadmin,
    :last_logged_in 

end
