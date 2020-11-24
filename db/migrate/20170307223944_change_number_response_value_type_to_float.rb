class ChangeNumberResponseValueTypeToFloat < ActiveRecord::Migration[4.2]
  def change
    change_column :decision_aid_user_responses, :number_response_value, :float
  end
end
