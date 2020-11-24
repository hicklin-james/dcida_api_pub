class CreateOptionProperties < ActiveRecord::Migration[4.2]
  def change
    create_table :option_properties do |t|

      t.string :information
      t.string :short_label
      t.belongs_to :option
      t.belongs_to :property
      t.belongs_to :decision_aid, null: false

      t.userstamps
      t.timestamps null: false
    end
  end
end
