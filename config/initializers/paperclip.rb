# config/initializers/paperclip.rb
require 'paperclip/media_type_spoof_detector'

module Paperclip
  class MediaTypeSpoofDetector
    old_spoofed = instance_method(:spoofed?)

    define_method(:spoofed?) do
      false
    end
  end
end

Paperclip.interpolates :fixed_filename do |attachment, style|
  attachment.instance.fixed_filename
end