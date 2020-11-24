class AddAdditionalColumnsToQuestions < ActiveRecord::Migration[4.2]
  def change
  	add_column :questions, :post_question_text, :text
  	add_column :questions, :post_question_text_published, :text
  	add_column :questions, :slider_midpoint_label, :string
  	add_column :questions, :unit_of_measurement, :string
  end
end
