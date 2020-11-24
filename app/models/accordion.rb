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

class Accordion < ApplicationRecord
  include Shared::CrossCloneable

  belongs_to :user
  belongs_to :decision_aid
  has_many :accordion_contents, dependent: :destroy, inverse_of: :accordion
  accepts_nested_attributes_for :accordion_contents, allow_destroy: true
  has_many :accordion_object_references

  validates :user_id, :decision_aid_id, presence: true

  default_scope { order(created_at: :asc) }
  
  after_update :update_references

  def update_references
    ActiveRecord::Base.transaction do 
      references = AccordionObjectReference.where(accordion_id: self.id)
      references.each do |reference|
        if obj = reference.object_type.constantize.find_by_id(reference.object_id)
          obj.save!
        else
          reference.destroy
        end
      end
    end
  end

  def deep_clone
    nac = self.dup
    accs = []
    self.accordion_contents.each do |ac|
      accs << ac.dup
    end
    nac.save!
    nac.reload
    accs.each do |ac|
      ac.accordion_id = nac.id
      ac.save!
    end
    return nac
  end

end
