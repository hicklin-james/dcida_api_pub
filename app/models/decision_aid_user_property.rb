# == Schema Information
#
# Table name: decision_aid_user_properties
#
#  id                    :integer          not null, primary key
#  property_id           :integer          not null
#  decision_aid_user_id  :integer          not null
#  weight                :integer          default(50)
#  order                 :integer          not null
#  color                 :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  traditional_value     :float
#  traditional_option_id :integer
#

class DecisionAidUserProperty < ApplicationRecord

  belongs_to :property
  belongs_to :decision_aid_user
  counter_culture :decision_aid_user

  validates :property_id, :decision_aid_user_id, :order, :color, presence: true
  validates :property_id, uniqueness: {scope: :decision_aid_user_id}

  # validates_numericality_of :traditional_value,
  #   :less_than_or_equal_to => 5,
  #   :greater_than_or_equal_to => 1,
  #   :only_integer => true,
  #   :allow_blank => true

  # validates_numericality_of :weight, 
  #   :less_than_or_equal_to => 100, 
  #   :greater_than_or_equal_to => 1, 
  #   :only_integer => true, 
  #   :allow_blank => true

  def self.batch_create_user_properties(created_properties)
    items = []
    created_properties.each do |user_property_hash|
      items.push DecisionAidUserProperty.create!(user_property_hash)
    end
    items
  end

  def self.batch_save_user_properties(properties)
    items = []
    properties.each do |property|
      property.save!
      items.push property
    end
    items
  end

  def self.batch_delete_user_properties(user_properties)
    user_properties.each do |user_property|
      user_property.destroy
    end
  end

end
