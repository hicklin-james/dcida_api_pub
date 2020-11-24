class AddCustomPageLabelsToDecisionAid < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :intro_page_label, :string, default: "Introduction"
    add_column :decision_aids, :about_me_page_label, :string, default: "About Me"
    add_column :decision_aids, :properties_page_label, :string, default: "My Values"
    add_column :decision_aids, :results_page_label, :string, default: "My Choice"
    add_column :decision_aids, :quiz_page_label, :string, default: "Review"
    add_column :decision_aids, :summary_page_label, :string, default: "Summary"
  end
end
