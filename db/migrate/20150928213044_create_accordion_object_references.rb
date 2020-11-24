class CreateAccordionObjectReferences < ActiveRecord::Migration[4.2]
  def change
    create_table :accordion_object_references do |t|
      t.integer :accordion_id
      t.integer :object_id
      t.string :object_type

      t.timestamps null: false
    end
  end
end
