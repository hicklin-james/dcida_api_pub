# == Schema Information
#
# Table name: download_items
#
#  id                   :integer          not null, primary key
#  download_type        :integer
#  downloaded           :boolean          default(FALSE)
#  file_location        :string
#  processed            :boolean          default(FALSE)
#  error                :boolean          default(FALSE)
#  created_by_user_id   :integer
#  updated_by_user_id   :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  decision_aid_user_id :integer
#  decision_aid_id      :integer
#

FactoryGirl.define do
  factory :download_item do
    
  end

end
