class AddAttributesForMoreInformationLinkAndFinalSummaryWordsToDecisionAid < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :more_information_button_text, :string
    add_column :decision_aids, :final_summary_text, :text
    add_column :decision_aids, :final_summary_text_published, :text
  end
end
