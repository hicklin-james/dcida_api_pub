class AddIntroPopupToDecisionAid < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :has_intro_popup, :boolean, default: false
    add_column :decision_aids, :intro_popup_information, :text
    add_column :decision_aids, :intro_popup_information_published, :text
  end
end
