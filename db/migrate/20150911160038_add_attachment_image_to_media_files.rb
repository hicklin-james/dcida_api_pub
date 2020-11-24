class AddAttachmentImageToMediaFiles < ActiveRecord::Migration[4.2]
  def self.up
    change_table :media_files do |t|
      t.attachment :image
    end
  end

  def self.down
    remove_attachment :media_files, :image
  end
end
