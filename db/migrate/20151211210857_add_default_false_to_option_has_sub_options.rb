class AddDefaultFalseToOptionHasSubOptions < ActiveRecord::Migration[4.2]
  def change
    change_column_null :options, :has_sub_options, false, false
  end
end
