class AddSectionTrackerTable < ActiveRecord::Migration[4.2]
  def change
    create_table :section_trackers do |t|
      t.belongs_to :progress_tracker
      t.belongs_to :sub_decision
      t.integer :page
      t.integer :section_tracker_order
    end
  end
end
