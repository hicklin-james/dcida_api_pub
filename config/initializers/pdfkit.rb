PDFKit.configure do |config|
  config.default_options = {

    # :margin_top => '0.05in',
    # :margin_bottom => '0.05in',
    # :margin_left => '0.05in',
    # :margin_right => '0.05in'
    
  }

  config.default_options[:load_error_handling] = 'ignore'

  config.wkhtmltopdf = '/usr/local/bin/wkhtmltopdf'
end