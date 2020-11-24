# == Schema Information
#
# Table name: latent_class_options
#
#  id              :integer          not null, primary key
#  latent_class_id :integer
#  option_id       :integer
#  weight          :float
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class LatentClassOption < ApplicationRecord
  include Shared::CrossCloneable
  belongs_to :latent_class
  belongs_to :option

  validates :latent_class_id, :option_id, :weight, presence: true
end
