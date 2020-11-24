# == Schema Information
#
# Table name: options
#
#  id                      :integer          not null, primary key
#  title                   :string           not null
#  label                   :string
#  description             :text
#  summary_text            :text
#  link_to_url             :string
#  decision_aid_id         :integer          not null
#  created_by_user_id      :integer
#  updated_by_user_id      :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  media_file_id           :integer
#  question_response_array :integer          default([]), is an Array
#  description_published   :text
#  summary_text_published  :text
#

class OptionShowSerializer < ActiveModel::Serializer

  attributes :id,
    :title,
    :description,
    :updated_at,
    :created_at,
    :created_by_user_id,
    :label,
    :summary_text,
    :decision_aid_id,
    :image,
    :image_thumb,
    :media_file_id,
    :decision_aid_id,
    :question_response_array,
    :has_sub_options,
    :option_order,
    :sub_decision_id,
    :generic_name

  has_many :sub_options, serializer: OptionShowSerializer

  def image
    url_prefix + object.media_file.image(:medium) unless object.media_file.nil?
  end

  def image_thumb
    url_prefix + object.media_file.image(:thumb) unless object.media_file.nil?
  end
  
  private

  def url_prefix
    RequestStore.store[:protocol] + RequestStore.store[:host_with_port]
  end
end
