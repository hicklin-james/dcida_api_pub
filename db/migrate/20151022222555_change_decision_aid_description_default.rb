class ChangeDecisionAidDescriptionDefault < ActiveRecord::Migration[4.2]
  def change
    change_column_null :decision_aids, :description, true
  end
end
