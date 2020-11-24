class ChangeColumnDefaultForSubDecisionRequiredOptionIds < ActiveRecord::Migration[4.2]
  def change
    change_column_default :sub_decisions, :required_option_ids, []
  end
end
