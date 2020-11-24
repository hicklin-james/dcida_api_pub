class ChangeResultsDceMatchOptionMatchHashToJson < ActiveRecord::Migration[4.2]
  def change
    remove_column :dce_results_matches, :option_match_hash, :json
    add_column :dce_results_matches, :option_match_hash, :json
  end
end
