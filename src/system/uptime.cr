module System
  module Uptime
    VERSION = "0.1.0"

    class Error < Exception
    end

    def self.seconds : Int64
      {% if flag?(:linux) %}
        begin
          File.read("/proc/uptime").split.first.to_f64.to_i64
        rescue ex
          raise Error.new(ex.message || "failed to read /proc/uptime")
        end
      {% else %}
        raise Error.new("System::Uptime currently supports Linux only")
      {% end %}
    end

    def self.minutes : Int64
      seconds // 60
    end

    def self.hours : Int64
      seconds // 3_600
    end

    def self.days : Int64
      seconds // 86_400
    end

    def self.uptime : String
      total_seconds = seconds
      days = total_seconds // 86_400
      remaining_seconds = total_seconds % 86_400
      hours = remaining_seconds // 3_600
      remaining_seconds %= 3_600
      minutes = remaining_seconds // 60
      secs = remaining_seconds % 60

      "#{days}:#{hours}:#{minutes}:#{secs}"
    end

    def self.boot_time : Time
      {% if flag?(:linux) %}
        Time.local - seconds.seconds
      {% else %}
        raise Error.new("System::Uptime currently supports Linux only")
      {% end %}
    end
  end
end
