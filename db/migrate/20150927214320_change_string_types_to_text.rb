class ChangeStringTypesToText < ActiveRecord::Migration[4.2]
  def up
    change_column :questions, :question_text, :text
    change_column :option_properties, :information, :text
    change_column :option_properties, :short_label, :text
  end

  def down
    change_column :questions, :question_text, :string
    change_column :option_properties, :information, :string
    change_column :option_properties, :short_label, :string
  end
end
