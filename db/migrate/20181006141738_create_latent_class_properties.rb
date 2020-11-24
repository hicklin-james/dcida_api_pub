class CreateLatentClassProperties < ActiveRecord::Migration[4.2]
  def change
    create_table :latent_class_properties do |t|
      t.belongs_to :latent_class
      t.belongs_to :property
      t.float :weight
      t.timestamps null: false
    end
  end
end
