class AddDefaultToPasswordProtected < ActiveRecord::Migration[4.2]
  def change
  	change_column_default :decision_aids, :password_protected, false
  end
end
