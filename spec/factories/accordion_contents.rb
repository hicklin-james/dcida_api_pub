# == Schema Information
#
# Table name: accordion_contents
#
#  id                 :integer          not null, primary key
#  accordion_id       :integer          not null
#  header             :string
#  content            :text
#  order              :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  content_published  :text
#  is_open_by_default :boolean
#  panel_color        :integer
#  decision_aid_id    :integer
#

FactoryGirl.define do
  factory :accordion_content do
    sequence :header do |n|
      "Header #{n}"
    end
    sequence :content do |n|
      "Content #{n}"
    end
  end
end
