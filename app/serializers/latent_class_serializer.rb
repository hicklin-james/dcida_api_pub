# == Schema Information
#
# Table name: latent_classes
#
#  id                 :integer          not null, primary key
#  decision_aid_id    :integer
#  class_order        :integer
#  created_by_user_id :integer
#  updated_by_user_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class LatentClassOptionSerializer < ActiveModel::Serializer
  attributes :id,
    :weight,
    :option_id
end

class LatentClassPropertySerializer < ActiveModel::Serializer
  attributes :id,
    :weight,
    :property_id
end

class LatentClassSerializer < ActiveModel::Serializer
  
  attributes :id,
  	:decision_aid_id

  has_many :latent_class_properties, serializer: LatentClassPropertySerializer, :key => :latent_class_properties_arr
  has_many :latent_class_options, serializer: LatentClassOptionSerializer, :key => :latent_class_options_arr
    
end

