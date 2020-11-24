class AddRedcapTokenToDecisionAid < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :redcap_token, :string
  end
end
