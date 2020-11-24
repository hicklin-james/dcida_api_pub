class AddQuestionResponseStyleToQuestions < ActiveRecord::Migration[4.2]
  def up
    add_column :questions, :question_response_style, :integer
    Question.all.each do |q|
      case q.question_response_type
      when "radio"
        q.question_response_style = "horizontal_radio"
      when "text"
        q.question_response_style = "normal_text"
      when "grid"
        q.question_response_style = "normal_grid"
      when "number"
        q.question_response_style = "normal_number"
      when "lookup_table"
        q.question_response_style = "normal_lookup_table"
      end
      q.save
    end
  end

  def down
    remove_column :questions, :question_response_style
  end
end
