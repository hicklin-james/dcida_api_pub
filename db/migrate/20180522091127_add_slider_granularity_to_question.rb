class AddSliderGranularityToQuestion < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :slider_granularity, :integer
  end
end
