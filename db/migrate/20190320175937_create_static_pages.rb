class CreateStaticPages < ActiveRecord::Migration[4.2]
  def change
    create_table :static_pages do |t|
      t.text :page_text
      t.text :page_text_published
      t.text :page_title
      t.integer :static_page_order, null: false
      t.references :decision_aid
      t.text :page_slug

      t.userstamps
      t.timestamps null: false
    end
  end
end
