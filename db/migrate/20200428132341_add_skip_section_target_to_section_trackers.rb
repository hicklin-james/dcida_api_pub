class AddSkipSectionTargetToSectionTrackers < ActiveRecord::Migration[4.2]
  def change
    add_column :section_trackers, :skip_section_target, :string, default: nil
  end
end
