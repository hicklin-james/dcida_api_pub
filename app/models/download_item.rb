# == Schema Information
#
# Table name: download_items
#
#  id                   :integer          not null, primary key
#  download_type        :integer
#  downloaded           :boolean          default(FALSE)
#  file_location        :string
#  processed            :boolean          default(FALSE)
#  error                :boolean          default(FALSE)
#  created_by_user_id   :integer
#  updated_by_user_id   :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  decision_aid_user_id :integer
#  decision_aid_id      :integer
#

=begin
Because we are interacting with the API using ajax, we need some way to keep track
of whether a downloadable item is ready to be downloaded or not.
=end

class DownloadItem < ApplicationRecord
  include Shared::UserStamps

  belongs_to :decision_aid, optional: true
  belongs_to :decision_aid_user, optional: true

  enum download_type: { decision_aid_download: 0, dce_template_download: 1, bw_template_download: 2, user_data_download: 3, patient_pdf_download: 4, non_patient_pdf_download: 5 }

  def make_pdf(pdf_kit, decision_aid_user)
    time_started = Time.now.strftime("%Y%m%d%H%M%S")
    rel_folder = "system/download_items/#{time_started}/#{decision_aid_user.decision_aid_id}"
    pdf_folder = Rails.env.test? ? "#{Rails.root}/rspec_tmp/#{rel_folder}" : "#{Rails.root}/public/#{rel_folder}"
    FileUtils::mkdir_p pdf_folder
    abs_path = "#{pdf_folder}/#{decision_aid_user.id} Summary PDF.pdf"
    rel_path = "#{rel_folder}/#{decision_aid_user.id} Summary PDF.pdf"

    pdf_kit.to_file(abs_path)
    self.file_location = rel_path
    self.processed = true
    self.save!
  end

  def self.remove_old_download_items
    old_download_items = DownloadItem.where("created_at < ?", 10.days.ago)
    old_download_items.destroy_all

    di_dir = "#{Rails.root}/public/system/download_items"
    download_item_files = Dir.entries(di_dir)
      .select {|entry| File.directory? File.join(di_dir,entry) and !(entry =='.' || entry == '..') }
    download_item_files.each do |di_folder_name|
      begin
        date = Date.strptime(di_folder_name,"%Y%m%d%H%M%S")
        if date < 10.days.ago
          FileUtils::rm_rf("#{di_dir}/#{di_folder_name}")
        end
      rescue ArgumentError => e
        puts e.message
        next
      end
    end
  end
end
