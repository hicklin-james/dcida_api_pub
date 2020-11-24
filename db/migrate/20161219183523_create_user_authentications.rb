class CreateUserAuthentications < ActiveRecord::Migration[4.2]
  def change
    create_table :user_authentications do |t|
      t.string :token, null: false
      t.boolean :is_superuser, null: false, default: false
      t.string :email, null: false
      t.timestamps null: false
    end
  end
end
