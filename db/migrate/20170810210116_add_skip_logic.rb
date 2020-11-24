class AddSkipLogic < ActiveRecord::Migration[4.2]
  def change
    add_column :question_responses, :has_skip_logic, :boolean, default: false
    add_column :question_responses, :skip_logic_type, :integer
    add_column :question_responses, :skip_question_id, :integer
    add_column :question_responses, :skip_page_url, :string

    reversible do |change|
      change.up do
        das = DecisionAid.all
        das.each do |da|
          demographic_nonhidden_questions = da.demographic_questions.where(hidden: false, question_id: nil).ordered
          demographic_nonhidden_questions.each_with_index do |q, i|
            q.question_order = i + 1
            q.save
          end
          demographic_hidden_questions = da.demographic_questions.where(hidden: true, question_id: nil).ordered
          demographic_hidden_questions.each_with_index do |q, i|
            q.question_order = i + 1
            q.save
          end

          quiz_nonhidden_questions = da.quiz_questions.where(hidden: false, question_id: nil).ordered
          quiz_nonhidden_questions.each_with_index do |q, i|
            q.question_order = i + 1
            q.save
          end
          quiz_hidden_questions = da.quiz_questions.where(hidden: true, question_id: nil).ordered
          quiz_hidden_questions.each_with_index do |q, i|
            q.question_order = i + 1
            q.save
          end
        end
      end
    end
  end
end
