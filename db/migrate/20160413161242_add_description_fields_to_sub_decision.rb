class AddDescriptionFieldsToSubDecision < ActiveRecord::Migration[4.2]
  def change
    add_column :sub_decisions, :options_information, :text
    add_column :sub_decisions, :options_information_published, :text
    add_column :sub_decisions, :other_options_information, :text
    add_column :sub_decisions, :other_options_information_published, :text
  end
end
