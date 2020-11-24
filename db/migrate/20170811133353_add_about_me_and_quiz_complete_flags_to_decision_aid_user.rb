class AddAboutMeAndQuizCompleteFlagsToDecisionAidUser < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aid_users, :about_me_complete, :boolean, default: false
    add_column :decision_aid_users, :quiz_complete, :boolean, default: false
  end
end
