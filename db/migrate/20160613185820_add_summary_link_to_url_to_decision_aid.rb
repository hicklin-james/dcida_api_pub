class AddSummaryLinkToUrlToDecisionAid < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :summary_link_to_url, :string
  end
end
