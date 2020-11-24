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

class UserAuthenticationSerializer < ActiveModel::Serializer
  attributes :token,
    :is_superuser,
    :email
end
