class CreateGraphics < ActiveRecord::Migration[4.2]
  def change
    create_table :graphics do |t|

      t.actable
      t.belongs_to :decision_aid
      t.string :title

      t.timestamps null: false
      t.userstamps
    end
  end
end
