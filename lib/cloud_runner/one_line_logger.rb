require "logger"

class OneLineLogger < Logger
  def initialize(*args)
    super
    customize_formatter
  end

  def customize_formatter
    last_line_len = 0
    self.formatter = proc do |severity, datetime, progname, msg|
      line = msg.split("\n").last
      "\r#{" " * last_line_len}\r#{line}".tap do
        last_line_len = line.size
      end
    end
  end
end
