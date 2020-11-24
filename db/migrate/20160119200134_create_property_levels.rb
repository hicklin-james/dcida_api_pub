class CreatePropertyLevels < ActiveRecord::Migration[4.2]
  def change
    create_table :property_levels do |t|
      t.text :information
      t.text :information_published
      t.integer :level_id
      t.belongs_to :property, null: false

      t.userstamps
      t.timestamps null: false
    end
  end
end
