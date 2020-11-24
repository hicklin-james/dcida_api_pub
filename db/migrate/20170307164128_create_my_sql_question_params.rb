class CreateMySqlQuestionParams < ActiveRecord::Migration[4.2]
  def change
    create_table :my_sql_question_params do |t|
      t.integer :param_source
      t.string :param_type
      t.string :value
      t.integer :my_sql_question_param_order
      t.belongs_to :question
      t.timestamps null: false
    end
  end
end
