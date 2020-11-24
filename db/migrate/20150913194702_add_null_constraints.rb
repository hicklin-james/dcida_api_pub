class AddNullConstraints < ActiveRecord::Migration[4.2]
  def change
    change_column_null :properties, :decision_aid_id, false
    change_column_null :option_properties, :option_id, false
    change_column_null :option_properties, :property_id, false
  end
end
