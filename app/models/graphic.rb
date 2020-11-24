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

class Graphic < ApplicationRecord
  include Shared::UserStamps
  include Shared::CrossCloneable

  actable
  belongs_to :decision_aid
  has_many :graphic_data, dependent: :destroy, inverse_of: :graphic

  accepts_nested_attributes_for :graphic_data, allow_destroy: true

  validates :decision_aid_id, :actable_type, presence: true

  def update_references
    ActiveRecord::Base.transaction do 
      references = GraphicObjectReference.where(graphic_id: self.id)
      references.each do |reference|
        if obj = reference.object_type.constantize.find_by_id(reference.object_id)
          obj.save!
        else
          reference.destroy
        end
      end
    end
  end
end
