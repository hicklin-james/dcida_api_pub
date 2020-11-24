class AddResponsePopupAttributesToQuestionResponse < ActiveRecord::Migration[4.2]
  def change
    add_column :question_responses, :popup_information, :text
    add_column :question_responses, :popup_information_published, :text
    add_column :question_responses, :include_popup_information, :boolean, default: false
  end
end
