class AddOptOutFlagToDceQuestionSetResponse < ActiveRecord::Migration[4.2]
  def change
    add_column :dce_question_set_responses, :is_opt_out, :boolean, default: false
  end
end
