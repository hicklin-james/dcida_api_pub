class AddSelfReferentialRelationshipToQuestion < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :question_id, :integer
  end
end
