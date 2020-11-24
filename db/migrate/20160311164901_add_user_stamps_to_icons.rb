class AddUserStampsToIcons < ActiveRecord::Migration[4.2]
  def change
    change_table :icons do |t|
      t.userstamps
    end
  end
end
