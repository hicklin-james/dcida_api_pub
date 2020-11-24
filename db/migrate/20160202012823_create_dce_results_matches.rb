class CreateDceResultsMatches < ActiveRecord::Migration[4.2]
  def change
    create_table :dce_results_matches do |t|
      t.belongs_to :decision_aid
      t.integer :response_combination, array: true
      t.json :option_match_hash, array: true

      t.timestamps null: false
    end
  end
end
