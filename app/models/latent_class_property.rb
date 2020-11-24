# == Schema Information
#
# Table name: latent_class_properties
#
#  id              :integer          not null, primary key
#  latent_class_id :integer
#  property_id     :integer
#  weight          :float
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class LatentClassProperty < ApplicationRecord
  include Shared::CrossCloneable
  belongs_to :latent_class
  belongs_to :property

  validates :latent_class_id, :property_id, :weight, presence: true
end
