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

class LatentClass < ApplicationRecord
  include Shared::CrossCloneable
  belongs_to :decision_aid
  has_many :latent_class_options
  has_many :latent_class_properties

  validates :decision_aid_id, presence: true

  accepts_nested_attributes_for :latent_class_options
  accepts_nested_attributes_for :latent_class_properties

  default_scope { order(class_order: :asc) }
end
