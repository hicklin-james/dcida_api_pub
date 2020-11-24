# == Schema Information
#
# Table name: accordions
#
#  id               :integer          not null, primary key
#  title            :string           not null
#  decision_aid_ids :integer          default([]), is an Array
#  user_id          :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  decision_aid_id  :integer
#

class AccordionContentSerializer < ActiveModel::Serializer
  attributes :id,
    :accordion_id,
    :header,
    :content,
    :is_open_by_default,
    :panel_color,
    :order,
    :decision_aid_id
end

class AccordionSerializer < ActiveModel::Serializer
  
  attributes :id,
    :title,
    :decision_aid_ids,
    :decision_aid_id

  has_many :accordion_contents, serializer: AccordionContentSerializer
    
end
