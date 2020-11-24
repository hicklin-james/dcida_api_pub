# == Schema Information
#
# Table name: animated_icon_array_graphics
#
#  id               :integer          not null, primary key
#  indicators_above :boolean          default(FALSE)
#  default_stage    :integer          default(0)
#

class AnimatedIconArrayGraphic < ApplicationRecord
  acts_as :graphic

  has_many :animated_icon_array_graphic_stages
  accepts_nested_attributes_for :animated_icon_array_graphic_stages, allow_destroy: true

  validate :enough_children_set

  after_update :update_references

  def graphic_to_html
    stages = self.animated_icon_array_graphic_stages.ordered.map{|gs|
      {
        "totalN" => gs.total_n,
        "separateDataPoints" => gs.seperate_values,
        "stepLabel" => gs.general_label,
        "dataPoints" => gs.graphic_data.ordered.map{ |gd|
          {
            "val" => gd.value,
            "color" => gd.color,
            "pointLabel" => gd.label
          }
        }
      }
    }
    %{
    <div style='width: 100%;' 
         sd-animated-icon-array-real sa-input-data=\'#{stages.to_json.to_s}\' 
         sa-indicators-above=\'#{self.indicators_above}\'
         sa-default-stage-index=\'#{self.default_stage}\'></div>
    }
  end

  private

  def update_references
    self.acting_as.update_references
  end

  def self.policy_class
    GraphicPolicy
  end

  def enough_children_set
    if self.animated_icon_array_graphic_stages.length == 0
      errors.add(:animated_icon_array_graphic_stages_count, "must be greater than zero")
    else
      self.animated_icon_array_graphic_stages.each do |gs|
        if gs.graphic_data.length == 0
          errors.add(:graphic_data, "must be set for each stage")
          break
        end
      end
    end
  end
end
