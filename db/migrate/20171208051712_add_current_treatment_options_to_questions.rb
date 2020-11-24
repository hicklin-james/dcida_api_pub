class AddCurrentTreatmentOptionsToQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :current_treatment_option_ids, :integer, array: true, default: []
  end
end
