class RemoveSomeOptOutFields < ActiveRecord::Migration[4.2]
  def change
    remove_column :decision_aids, :fallback_option
    remove_column :decision_aids, :fallback_on_option
    remove_column :properties, :opt_out_information
    remove_column :properties, :opt_out_information_published
  end
end
