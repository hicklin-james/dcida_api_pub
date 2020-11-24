class CreateSummaryPages < ActiveRecord::Migration[4.2]
  def up
    create_table :summary_pages do |t|
      t.belongs_to :decision_aid, null: false
      t.integer :summary_panels_count, default: 0, null: false
      t.boolean :include_admin_summary_email, default: false
      t.boolean :is_primary, default: false
      t.string :summary_email_addresses, array: true 

      t.userstamps
      t.timestamps null: false
    end

    add_reference :summary_panels, :summary_page, index: true

    DecisionAid.all.each do |da|
      if da.summary_panels.count > 0
        sp = SummaryPage.new(decision_aid_id: da.id, is_primary: true)
        if da.include_admin_summary_email
          sp.include_admin_summary_email = true
          da.include_admin_summary_email = false
        end
        if da.summary_email_addresses.length > 0
          sp.summary_email_addresses = da.summary_email_addresses
        end
        sp.save!
        da.save!
      end
    end

    SummaryPanel.all.each do |sp|
      dasp = DecisionAid.find(sp.decision_aid_id).summary_pages.where(is_primary: true).first
      sp.summary_page_id = dasp.id
      sp.save!
    end

    change_column :summary_panels, :summary_page_id, :integer, null: false
  end

  def down
    drop_table :summary_pages
    remove_reference :summary_panels, :summary_page
  end
end
