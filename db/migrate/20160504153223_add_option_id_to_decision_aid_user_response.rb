class AddOptionIdToDecisionAidUserResponse < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aid_user_responses, :option_id, :integer
  end
end
