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

class Icon < ApplicationRecord
  include Shared::UserStamps
  include Shared::CrossCloneable

  validates :decision_aid_id, presence: true

  belongs_to :decision_aid, optional: true

  has_attached_file :image, styles: { thumb: "75x75#" }
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/
  
end
