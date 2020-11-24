class AddIndexesToTables < ActiveRecord::Migration[4.2]
  def change
    add_index :decision_aids, :slug
    add_index :decision_aid_user_sessions, :decision_aid_user_id
    add_index :options, :decision_aid_id
    add_index :properties, :decision_aid_id
    add_index :option_properties, [:decision_aid_id, :option_id, :property_id], name: "option_property_index"
    add_index :questions, :decision_aid_id
    add_index :question_responses, [:decision_aid_id, :question_id]
    add_index :decision_aid_user_responses, [:decision_aid_user_id, :question_id, :question_response_id], name: "decision_aid_user_response_index"
    add_index :decision_aid_user_option_properties, [:decision_aid_user_id, :option_id, :property_id, :option_property_id], name: "decision_aid_user_option_property_index"
    add_index :decision_aid_user_properties, [:decision_aid_user_id, :property_id], name: "decision_aid_user_property_index"
    add_index :decision_aid_user_dce_question_set_responses, [:decision_aid_user_id, :question_set, :dce_question_set_response_id], name: "decision_aid_user_dce_question_set_response_index"
    add_index :dce_question_set_responses, [:decision_aid_id, :question_set], name: "dce_question_set_response_index"
    add_index :dce_results_matches, [:decision_aid_id, :response_combination], name: "dce_results_match_index"
    add_index :icons, :decision_aid_id
    add_index :property_levels, :property_id
    add_index :accordion_contents, :accordion_id
  end
end
