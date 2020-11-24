class CreateOptions < ActiveRecord::Migration[4.2]
  def change
    create_table :options do |t|

      t.string :title, null: false
      t.string :label
      t.text :description
      t.text :summary_text
      t.string :link_to_url
      t.belongs_to :decision_aid, null: false

      t.userstamps
      t.timestamps null: false
    end
  end
end
