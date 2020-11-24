class CreateUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :users do |t|

      t.string :email, null: false, default: ''
      t.string :first_name
      t.string :last_name
      t.string :password_digest, null: false
      t.boolean :is_superadmin, null: false, default: false

      t.timestamps null: false
    end
  end
end
