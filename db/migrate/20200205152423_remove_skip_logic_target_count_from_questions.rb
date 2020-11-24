class RemoveSkipLogicTargetCountFromQuestions < ActiveRecord::Migration[4.2]
  def change
    remove_column :questions, :skip_logic_target_count 
  end
end
