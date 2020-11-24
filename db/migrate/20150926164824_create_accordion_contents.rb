class CreateAccordionContents < ActiveRecord::Migration[4.2]
  def change
    create_table :accordion_contents do |t|

      t.belongs_to :accordion, null: false
      t.string :header
      t.text :content
      t.integer :order

      t.timestamps null: false
    end
  end
end
