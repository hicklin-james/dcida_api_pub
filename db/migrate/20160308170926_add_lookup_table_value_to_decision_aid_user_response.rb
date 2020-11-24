class AddLookupTableValueToDecisionAidUserResponse < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aid_user_responses, :lookup_table_value, :float
  end
end
