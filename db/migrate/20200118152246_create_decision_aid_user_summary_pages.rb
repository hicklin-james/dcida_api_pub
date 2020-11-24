class CreateDecisionAidUserSummaryPages < ActiveRecord::Migration[4.2]
  def change
    create_table :decision_aid_user_summary_pages do |t|
      t.belongs_to :decision_aid_user
      t.belongs_to :summary_page
      t.attachment :summary_page_file
      t.timestamps null: false
    end
  end
end
