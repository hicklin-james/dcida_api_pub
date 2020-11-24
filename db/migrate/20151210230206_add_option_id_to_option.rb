class AddOptionIdToOption < ActiveRecord::Migration[4.2]
  def change
    add_column :options, :option_id, :integer
    add_column :options, :has_sub_options, :boolean
  end
end
