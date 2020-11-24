# == Schema Information
#
# Table name: option_properties
#
#  id                    :integer          not null, primary key
#  information           :text
#  short_label           :text
#  option_id             :integer          not null
#  property_id           :integer          not null
#  decision_aid_id       :integer          not null
#  created_by_user_id    :integer
#  updated_by_user_id    :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  information_published :text
#  ranking               :integer
#

class OptionPropertyPreviewSerializer < ActiveModel::Serializer

  attributes :id,
    :information_published,
    :short_label,
    :option_id,
    :property_id,
    :decision_aid_id

end
