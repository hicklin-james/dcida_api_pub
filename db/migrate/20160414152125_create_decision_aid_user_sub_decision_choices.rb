class CreateDecisionAidUserSubDecisionChoices < ActiveRecord::Migration[4.2]
  def change
    create_table :decision_aid_user_sub_decision_choices do |t|

      t.belongs_to :decision_aid_user
      t.belongs_to :sub_decision
      t.belongs_to :option

      t.timestamps null: false
    end
  end
end
