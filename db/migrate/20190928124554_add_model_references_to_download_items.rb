class AddModelReferencesToDownloadItems < ActiveRecord::Migration[4.2]
  def change
    add_reference :download_items, :decision_aid_user, index: true
    add_reference :download_items, :decision_aid, index: true
  end
end
