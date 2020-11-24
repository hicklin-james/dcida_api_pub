class AddProgressTrackerTable < ActiveRecord::Migration[4.2]
  def change
    create_table :progress_trackers do |t|
      t.belongs_to :decision_aid_user
    end
  end
end
