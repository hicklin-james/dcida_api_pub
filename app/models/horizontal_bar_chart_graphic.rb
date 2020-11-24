# == Schema Information
#
# Table name: horizontal_bar_chart_graphics
#
#  id                  :integer          not null, primary key
#  selected_index      :string
#  selected_index_type :integer
#  max_value           :string
#

class HorizontalBarChartGraphic < ApplicationRecord
  acts_as :graphic

  enum selected_index_type: {decimal: 0, question_response: 1}
  validates :max_value, presence: true
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

    html = "<div sd-horizontal-bar-chart sa-chartid=\"test-#{SecureRandom.uuid}\" style='width: 100%;'"
    html += " sa-selected-index=\"#{self.selected_index}\"" if !self.selected_index.blank?
    html += " sa-max-value=\"#{self.max_value}\""
    html += " sa-include-axis=\'true\'"
    html += " sa-data=\'#{graphic_data.to_json.to_s}\'></div>"
    html

  end

  def validate_data_length
    true
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
