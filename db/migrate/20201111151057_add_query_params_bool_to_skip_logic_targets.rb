class AddQueryParamsBoolToSkipLogicTargets < ActiveRecord::Migration[5.2]
  def change
    add_column :skip_logic_targets, :include_query_params, :boolean, default: false
  end
end
