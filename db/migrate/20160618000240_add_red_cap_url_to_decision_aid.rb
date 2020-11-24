class AddRedCapUrlToDecisionAid < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :redcap_url, :string
  end
end
