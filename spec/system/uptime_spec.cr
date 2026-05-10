require "../spec_helper"

describe System::Uptime do
  it "has the expected version" do
    System::Uptime::VERSION.should eq("0.2.0")
  end

  it "responds to seconds" do
    System::Uptime.seconds.should be_a(Int64)
  end

  it "returns a plausible number of seconds" do
    minimum = ENV["CI"]? ? 30_i64 : 120_i64
    System::Uptime.seconds.should be > minimum
  end

  it "returns minutes" do
    System::Uptime.minutes.should be_a(Int64)
    System::Uptime.minutes.should be >= 0
  end

  it "returns hours" do
    System::Uptime.hours.should be_a(Int64)
    System::Uptime.hours.should be >= 0
  end

  it "returns days" do
    System::Uptime.days.should be_a(Int64)
    System::Uptime.days.should be >= 0
  end

  it "returns a colon-separated uptime string" do
    System::Uptime.uptime.should match(/^\d+:\d+:\d+:\d+$/)
  end

  it "returns a boot time" do
    boot_time = System::Uptime.boot_time
    boot_time.should be_a(Time)
    boot_time.should be < Time.local
  end

  it "keeps seconds and boot time in sync" do
    expected_boot_time = Time.local - System::Uptime.seconds.seconds
    actual_boot_time = System::Uptime.boot_time

    (actual_boot_time.to_unix - expected_boot_time.to_unix).abs.should be <= 2
  end
end
