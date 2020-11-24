# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

class Logger
  def format_message(severity, timestamp, progname, msg)
    line = ''
    Kernel.caller.each{|entry|
      if (entry.include? Rails.root.to_s)
        line = " #{entry.gsub(Rails.root.to_s,'').gsub(/\/(.+)\:in `(.+)'/, "\\1 -> \\2")}"
        break
      end
    }

    if Sidekiq.server?
      "[#{timestamp.strftime("%Y%m%d.%H:%M:%S")}] #{severity} #{Thread.current.object_id} #{line}: #{msg}\r\n"
    else
      "[#{timestamp.strftime("%Y%m%d.%H:%M:%S")}] #{severity}#{line}: #{msg}\r\n"
    end
  end
end