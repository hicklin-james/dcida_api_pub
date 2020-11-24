class AddJsonResponseToDecisionAidUserResponse < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aid_user_responses, :json_response_value, :json
  end
end
