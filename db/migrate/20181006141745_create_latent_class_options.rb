class CreateLatentClassOptions < ActiveRecord::Migration[4.2]
  def change
    create_table :latent_class_options do |t|
      t.belongs_to :latent_class
      t.belongs_to :option
      t.float :weight
      t.timestamps null: false
    end
  end
end
