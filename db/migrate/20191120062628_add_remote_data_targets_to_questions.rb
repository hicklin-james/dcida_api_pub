class AddRemoteDataTargetsToQuestions < ActiveRecord::Migration[4.2]
  def change
  	add_column :questions, :remote_data_target, :boolean, default: false
  	add_column :questions, :remote_data_target_type, :integer
  end
end
