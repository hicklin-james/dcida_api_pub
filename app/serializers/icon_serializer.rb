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

class IconSerializer < ActiveModel::Serializer

  attributes :id,
    :icon_type,
    :image,
    :title,
    :url

  def image
    url_prefix + object.image(:thumb)
  end

  def title
    object.image.original_filename
  end

  private

  def url_prefix
    RequestStore.store[:protocol] + RequestStore.store[:host_with_port]
  end

end
