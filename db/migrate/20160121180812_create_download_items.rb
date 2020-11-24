class CreateDownloadItems < ActiveRecord::Migration[4.2]
  def change
    create_table :download_items do |t|

      t.integer :download_type
      t.boolean :downloaded, default: false
      t.string :file_location
      t.boolean :processed, default: false
      t.boolean :error, default: false

      t.userstamps
      t.timestamps null: false
    end
  end
end
