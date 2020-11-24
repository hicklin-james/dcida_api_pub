class RemoveLinkToUrlFromOptions < ActiveRecord::Migration[4.2]
  def change
    remove_column :options, :link_to_url
  end
end
