class AddRankingTypeToOptionProperty < ActiveRecord::Migration[4.2]
  def change
    add_column :option_properties, :ranking_type, :integer
    change_column :option_properties, :ranking, :text
  end
end
