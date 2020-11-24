# == Schema Information
#
# Table name: icon_array_graphics
#
#  id                  :integer          not null, primary key
#  selected_index      :string
#  selected_index_type :integer
#  num_per_row         :integer
#

class IconArrayGraphic < ApplicationRecord

  acts_as :graphic

  validates :num_per_row, presence: true
  validate :validate_graphic_data_length

  after_update :update_references

  def graphic_to_html
    graphic_data = GraphicDatum.where(graphic_id: self.acting_as.id).ordered.map { |gd|
      {
        value: gd.value,
        label: gd.label,
        color: gd.color,
        sub_value: gd.sub_value
      }
    }

    html = "<div sd-icon-array sa-chartid=\"test-#{SecureRandom.uuid}\" style='width: 100%;'"
    html += " sa-selected-index=\"#{self.selected_index}\"" if !self.selected_index.blank?
    html += " sa-num-per-row=\'#{self.num_per_row}\'"
    html += " sa-data=\'#{graphic_data.to_json.to_s}\'></div>"
    html

  end

  private

  def validate_graphic_data_length
    if self.graphic_data.reject(&:marked_for_destruction?).length == 0
      errors.add(:graphic_data, "must have at least one data point")
    end
  end

  def update_references
    self.acting_as.update_references
  end

  def self.policy_class
    GraphicPolicy
  end
end
