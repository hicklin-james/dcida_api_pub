class CreateAccordions < ActiveRecord::Migration[4.2]
  def change
    create_table :accordions do |t|

      t.string :title, null: false
      t.integer :decision_aid_ids, array: true, default: []
      t.belongs_to :user, null: false

      t.timestamps null: false
    end
  end
end
