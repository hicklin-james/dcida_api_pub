class AddSummaryEmailAAttributesToDecisionAid < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :include_admin_summary_email, :bool, default: false
    add_column :decision_aids, :include_user_summary_email, :bool, default: false
    add_column :decision_aids, :user_summary_email_text, :text, default: "If you would like these results emailed to you, enter your email address here:"
  end
end
