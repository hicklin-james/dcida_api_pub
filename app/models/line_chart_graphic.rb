# == Schema Information
#
# Table name: line_chart_graphics
#
#  id          :integer          not null, primary key
#  x_label     :string
#  y_label     :string
#  chart_title :string
#  min_value   :integer
#  max_value   :integer
#
class LineChartGraphic < ApplicationRecord

  acts_as :graphic

  validates :min_value, :max_value, presence: true
  validate :validate_graphic_data_length

  after_update :update_references

  def graphic_to_html
    graphic_data = GraphicDatum.where(graphic_id: self.acting_as.id).ordered

    overallData = Hash.new
    overallData["maxValue"] = self.max_value
    overallData["minValue"] = self.min_value
    overallData["title"] = self.chart_title
    overallData["xLabel"] = self.x_label
    overallData["yLabel"] = self.y_label
    overallData["data"] = Array.new

    series = graphic_data.group_by(&:sub_value)
    series.each_with_index do |(k, v), index|
      overallData["data"].push Hash.new
      overallData["data"][index]["label"] = v[0].sub_value
      overallData["data"][index]["values"] = v.map{|dp| dp.value}
    end

    overallData["categories"] = series.first[1].map{|dp| dp.label}

    html = "<div sd-line-chart sa-chartid=\"test-#{SecureRandom.uuid}\" style='width: 100%;'"
    html += " sa-chart-data=\'#{overallData.to_json.to_s}\'></div>"
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
