class AddSliderLabelsToQuestion < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :slider_left_label, :string
    add_column :questions, :slider_right_label, :string
  end
end
