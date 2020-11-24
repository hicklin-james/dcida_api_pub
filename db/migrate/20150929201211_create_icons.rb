class CreateIcons < ActiveRecord::Migration[4.2]
  def change
    create_table :icons do |t|

      t.integer :decision_aid_id, null: false
      t.string :url
      t.integer :icon_type

      t.timestamps null: false
    end
  end
end
