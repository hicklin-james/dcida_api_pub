class AddRedcapFieldsToQuestionResponses < ActiveRecord::Migration[4.2]
  def change
    add_column :question_responses, :redcap_response_value, :string
  end
end
