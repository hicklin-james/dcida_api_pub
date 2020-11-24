class AddRankingToOptionProperty < ActiveRecord::Migration[4.2]
  def change
    add_column :option_properties, :ranking, :integer
  end
end
