class AddNumberValueToDecisionAidUserResponse < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aid_user_responses, :number_response_value, :integer
  end
end
