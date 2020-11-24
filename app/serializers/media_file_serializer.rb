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

class MediaFileSerializer < ActiveModel::Serializer

  attributes :id,
    :thumb,
    :image,
    :title,
    :filelink,
    :icon

  def icon
    url_prefix + object.image(:icon)
  end

  def thumb
    url_prefix + object.image(:thumb)
  end

  def image
    url_prefix + object.image(:medium)
  end

  def title
    object.image.original_filename
  end

  def filelink
    url_prefix + object.image(:medium)
  end

  private

  def url_prefix
    RequestStore.store[:protocol] + RequestStore.store[:host_with_port]
  end

end
