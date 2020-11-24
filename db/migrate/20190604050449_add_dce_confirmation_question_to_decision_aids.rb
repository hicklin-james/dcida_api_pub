class AddDceConfirmationQuestionToDecisionAids < ActiveRecord::Migration[4.2]
  def change
  	add_column :decision_aids, :include_dce_confirmation_question, :boolean, default: false
  	add_column :decision_aids, :dce_confirmation_question, :text
  	add_column :decision_aids, :dce_confirmation_question_published, :text
  end
end
