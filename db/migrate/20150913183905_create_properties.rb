class CreateProperties < ActiveRecord::Migration[4.2]
  def change
    create_table :properties do |t|
      t.string :title
      t.text :selection_about
      t.text :long_about
      t.belongs_to :decision_aid

      t.userstamps
      t.timestamps null: false
    end
  end
end
