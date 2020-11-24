class AddDceOptionPrefixToDecisionAids < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :dce_option_prefix, :string, default: "Option"
  end
end
