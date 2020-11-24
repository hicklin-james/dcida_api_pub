class CreateNavLinks < ActiveRecord::Migration[4.2]
  def change
    create_table :nav_links do |t|
      t.string :link_href
      t.string :link_text
      t.integer :link_location
      t.integer :nav_link_order, null: false
      t.references :decision_aid

      t.userstamps
      t.timestamps null: false
    end
  end
end
