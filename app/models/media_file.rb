# == Schema Information
#
# Table name: media_files
#
#  id                 :integer          not null, primary key
#  media_type         :integer
#  user_id            :integer
#  created_by_user_id :integer
#  updated_by_user_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  image_file_name    :string
#  image_content_type :string
#  image_file_size    :integer
#  image_updated_at   :datetime
#

class MediaFile < ApplicationRecord

  enum media_type: [ :image, :video, :document ]

  has_attached_file :image, styles: { icon: "75x75#", thumb: "100x100>", medium: "300x300>", result: "280x185#" }, default_url: "/public/images/:style/missing.png"
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  scope :ordered, ->{ order(created_at: :desc) }

  # media files MUST belong to a user
  belongs_to :user
  validates :user, presence: true

  has_many :options
  
end
