# == Schema Information
#
# Table name: graphics
#
#  id                 :integer          not null, primary key
#  actable_id         :integer
#  actable_type       :string
#  decision_aid_id    :integer
#  title              :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  created_by_user_id :integer
#  updated_by_user_id :integer
#

class GraphicSerializer < ActiveModel::Serializer
  attributes :actable_type,
    :title
end
