class AddOptionIdToMediaFile < ActiveRecord::Migration[4.2]
  def change
  	add_reference :options, :media_file, index: true
  	add_foreign_key :options, :media_files
  end
end
