class ChangeDecisionAidTypeDefault < ActiveRecord::Migration[4.2]
  def change
    change_column_default :decision_aids, :decision_aid_type, nil
  end
end
