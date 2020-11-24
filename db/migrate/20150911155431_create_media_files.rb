class CreateMediaFiles < ActiveRecord::Migration[4.2]
  def change
    create_table :media_files do |t|

      t.integer :media_type
      t.belongs_to :user

      t.userstamps
      t.timestamps null: false
    end
  end
end
