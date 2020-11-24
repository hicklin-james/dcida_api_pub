class CreateGraphicObjectReferences < ActiveRecord::Migration[4.2]
  def change
    create_table :graphic_object_references do |t|
      t.belongs_to :graphic
      t.integer :object_id
      t.string :object_type

      t.timestamps null: false
    end
  end
end
