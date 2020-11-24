class AddTermsAcceptedToUsers < ActiveRecord::Migration[4.2]
  def up
    add_column :users, :terms_accepted, :boolean
    User.all.update_all(:terms_accepted => :true)
  end

  def down
    remove_column :users, :terms_accepted
  end
end
