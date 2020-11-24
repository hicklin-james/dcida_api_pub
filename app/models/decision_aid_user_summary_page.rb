# == Schema Information
#
# Table name: decision_aid_user_summary_pages
#
#  id                             :integer          not null, primary key
#  decision_aid_user_id           :integer
#  summary_page_id                :integer
#  summary_page_file_file_name    :string
#  summary_page_file_content_type :string
#  summary_page_file_file_size    :integer
#  summary_page_file_updated_at   :datetime
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#

class DecisionAidUserSummaryPage < ApplicationRecord
  validates :decision_aid_user, :summary_page, presence: true
  has_attached_file :summary_page_file,
    path: ":rails_root/public/system/:class/:attachment/:id_partition/:style/:fixed_filename",
    url: "/system/:class/:attachment/:id_partition/:style/:fixed_filename"
  validates_attachment_content_type :summary_page_file, content_type: ['application/pdf']

  belongs_to :decision_aid_user
  belongs_to :summary_page

  def fixed_filename
     "#{self.id.to_s}-#{self.decision_aid_user_id}.pdf"
  end

  # returns the summary pages that were generated
  def self.generateForDecisionAidUser(decision_aid_user, dteds)
    # need to generate PDFs for summary pages that are used as data targets AND those that
    # have auto emails set
    summary_pages = SummaryPage
      .where(decision_aid_id: decision_aid_user.decision_aid_id)

    if dteds.length > 0
      summary_pages = summary_pages.where("summary_pages.include_admin_summary_email = 't' OR summary_pages.id IN (#{dteds.join(',')})")
    else
      summary_pages = summary_pages.where("summary_pages.include_admin_summary_email = 't'")
    end

    summary_pages.each do |sp|
      parsed_html = decision_aid_user.prepare_summary_html(sp)
      kit = PDFKit.new(parsed_html, :page_size => 'Letter', :viewport_size => "1140x1477")
      #pdf = kit.to_pdf
      tempname = Time.now.strftime("%Y%m%d%H%M%S") + "-#{sp.id.to_s}-#{decision_aid_user.id}"
      f = Tempfile.new(tempname)

      kit.to_file(f.path)
      f.rewind()
      
      dausp = DecisionAidUserSummaryPage.find_by(summary_page_id: sp.id, decision_aid_user_id: decision_aid_user.id)
      if dausp
        dausp.summary_page_file = f
        dausp.save!
      else
        dausp = DecisionAidUserSummaryPage.create!(
          decision_aid_user_id: decision_aid_user.id,
          summary_page_id: sp.id,
          summary_page_file: f
        )
      end
      f.close()
      f.unlink()
    end

    # delete old summary pages
    DecisionAidUserSummaryPage.where(decision_aid_user_id: decision_aid_user.id)
                              .where
                              .not(summary_page_id: summary_pages.map(&:id))
                              .destroy_all

    return summary_pages
  end
end
