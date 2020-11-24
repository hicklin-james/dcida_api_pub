class AddSubDecisionSpecificMyChoiceInformationToSubDecisions < ActiveRecord::Migration[4.2]
  def change
    add_column :sub_decisions, :my_choice_information, :text
    add_column :sub_decisions, :my_choice_information_published, :text
  end
end
