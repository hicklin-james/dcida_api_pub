class AddPdfDownloadButtonToDecisionAid < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :include_download_pdf_button, :boolean, default: false
  end
end
