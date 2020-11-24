class DecisionAidMailer < ApplicationMailer
  def summary_mail(daid, dauid, summary_html, send_address)
    if !summary_html.blank?
      kit = PDFKit.new(summary_html, :page_size => 'Letter', :viewport_size => "1140x1477")
      @decisionAid = DecisionAid.find daid
      pdf = kit.to_pdf
      attachments["summary.pdf"] = pdf

      subject = "Decision Aid Summary"
      dau = DecisionAidUser.find_by(id: dauid)
      if dau and dau.pid
        subject += " - patient identification #{dau.pid}"
      end

      if !send_address.blank?
        mail(to: send_address, subject: subject, from: "noreply@#{ENV['MAILER_BASE']}")
      else
        nonEmptyAddress = @decisionAid.summary_email_addresses.reject {|e| e.empty?}
        addresses = nonEmptyAddress.join(",")
        if !addresses.blank?
          mail(to: addresses, subject: subject, from: "noreply@#{ENV['MAILER_BASE']}")
        end
      end
    end
  end

  def non_primary_summary_mail(dausp, decisionAid)
    #kit = PDFKit.new(parsed_html, :page_size => 'Letter', :viewport_size => "1140x1477")
    @decisionAid = decisionAid
    #pdf = kit.to_pdf
    attachments["summary.pdf"] = File.read(dausp.summary_page_file.path)
    nonEmptyAddress = dausp.summary_email_addresses.reject {|e| e.empty?}
    addresses = nonEmptyAddress.join(",")

    if !addresses.blank?
      subject = "Decision Aid Summary"
      if dausp.decision_aid_user.pid
        subject += " - patient identification #{dausp.decision_aid_user.pid}"
      end
      mail(to: addresses, subject: subject, from: "noreply@#{ENV['MAILER_BASE']}", template_name: "summary_mail")
    end
  end
end
