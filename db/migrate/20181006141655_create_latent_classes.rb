class CreateLatentClasses < ActiveRecord::Migration[4.2]
  def change
    create_table :latent_classes do |t|
      t.belongs_to :decision_aid
      t.integer :class_order
      t.userstamps
      t.timestamps null: false
    end
  end
end
