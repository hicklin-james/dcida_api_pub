class CreateUserPermissions < ActiveRecord::Migration[4.2]
  def change
    create_table :user_permissions do |t|
      t.references :user
      t.references :decision_aid
      t.integer :permission_value

      t.timestamps null: false
    end
  end
end
