class CreateDecisionAids < ActiveRecord::Migration[4.2]
  def change
    create_table :decision_aids do |t|

      t.string :slug, null: false
      t.string :title, null: false
      t.text :description, null: false

      t.userstamps
      t.timestamps null: false
    end
  end
end
