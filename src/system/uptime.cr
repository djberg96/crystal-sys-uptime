require "c/time"
require "c/sys/time"

{% if flag?(:freebsd) || flag?(:openbsd) || flag?(:netbsd) || flag?(:dragonfly) %}
  require "c/sysctl"
{% end %}

{% if flag?(:darwin) %}
  lib LibC
    fun sysctl(name : Int32*, namelen : UInt32, oldp : Void*, oldlenp : SizeT*, newp : Void*, newlen : SizeT) : Int32
  end
{% end %}

module System
  module Uptime
    VERSION = "0.1.0"
    CTL_KERN = 1
    KERN_BOOTTIME = 21

    class Error < Exception
    end

    def self.seconds : Int64
      {% if flag?(:linux) %}
        begin
          File.read("/proc/uptime").split.first.to_f64.to_i64
        rescue ex
          raise Error.new(ex.message || "failed to read /proc/uptime")
        end
      {% elsif flag?(:darwin) || flag?(:freebsd) || flag?(:openbsd) || flag?(:netbsd) || flag?(:dragonfly) %}
        Time.utc.to_unix - kernel_boot_time_seconds
      {% else %}
        raise Error.new("System::Uptime currently supports Linux, macOS, and BSD only")
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
      {% elsif flag?(:darwin) || flag?(:freebsd) || flag?(:openbsd) || flag?(:netbsd) || flag?(:dragonfly) %}
        Time.unix(kernel_boot_time_seconds).in(Time::Location.local)
      {% else %}
        raise Error.new("System::Uptime currently supports Linux, macOS, and BSD only")
      {% end %}
    end

    private def self.kernel_boot_time_seconds : Int64
      mib = Int32[CTL_KERN, KERN_BOOTTIME]

      {% if flag?(:netbsd) %}
        boot_time = LibC::Timespec.new
        size = LibC::SizeT.new(sizeof(LibC::Timespec))

        if LibC.sysctl(mib.to_unsafe, mib.size.to_u32, pointerof(boot_time).as(Void*), pointerof(size), Pointer(Void).null, 0) == 0
          return boot_time.tv_sec.to_i64
        end

        fallback_boot_time = boot_time_seconds_from_who
        return fallback_boot_time if fallback_boot_time
      {% else %}
        boot_time = LibC::Timeval.new
        size = LibC::SizeT.new(sizeof(LibC::Timeval))

        if LibC.sysctl(mib.to_unsafe, mib.size.to_u32, pointerof(boot_time).as(Void*), pointerof(size), Pointer(Void).null, 0) == 0
          return boot_time.tv_sec.to_i64
        end

        fallback_boot_time = boot_time_seconds_from_who
        return fallback_boot_time if fallback_boot_time
      {% end %}

      raise Error.new("sysctl(KERN_BOOTTIME) failed: #{Errno.value}")
    end

    private def self.boot_time_seconds_from_who : Int64?
      output = IO::Memory.new
      status = Process.run("who", ["-b"], output: output, error: Process::Redirect::Close)
      return unless status.success?

      parts = output.to_s.split
      return unless parts.size >= 5 && parts[0] == "system" && parts[1] == "boot"

      year = parts[5]?.try(&.to_i) || Time.local.year
      parsed_time = Time.parse("#{parts[2]} #{parts[3]} #{parts[4]} #{year}", "%b %d %H:%M %Y", Time::Location.local)

      if parts.size == 5 && parsed_time > Time.local
        parsed_time = Time.parse("#{parts[2]} #{parts[3]} #{parts[4]} #{year - 1}", "%b %d %H:%M %Y", Time::Location.local)
      end

      parsed_time.to_unix
    rescue Time::Format::Error
      nil
    end
  end
end
