# == Schema Information
#
# Table name: icons
#
#  id                 :integer          not null, primary key
#  decision_aid_id    :integer          not null
#  url                :string
#  icon_type          :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  image_file_name    :string
#  image_content_type :string
#  image_file_size    :integer
#  image_updated_at   :datetime
#  created_by_user_id :integer
#  updated_by_user_id :integer
#

FactoryGirl.define do
  factory :icon do

  end
end
