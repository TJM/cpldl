require "rails_helper"

describe Duration do

  it "returns the seconds in a string format" do
    expect(Duration.duration_str(1)).to eq("0:01")
    expect(Duration.duration_str(90)).to eq("1:30")
    expect(Duration.duration_str(120)).to eq("2:00")
    expect(Duration.duration_str(0)).to eq("0:00")
    expect(Duration.duration_str(-1)).to eq("0:00")
  end

  it "returns the rounded minutes" do
    expect(Duration.minutes_str(90)).to eq("1 Minute")
    expect(Duration.minutes_str(119)).to eq("1 Minute")
    expect(Duration.minutes_str(120)).to eq("2 Minutes")
    expect(Duration.minutes_str(600)).to eq("10 Minutes")
    expect(Duration.minutes_str(59)).to eq("0 Minutes")
    expect(Duration.minutes_str(-1)).to eq("0 Minutes")
  end

  it "converts a duration string to number of seconds" do
    expect(Duration.duration_str_to_int("1:00")).to eq(60)
    expect(Duration.duration_str_to_int("0:20")).to eq(20)
    expect(Duration.duration_str_to_int("2:20")).to eq(140)
    expect(Duration.duration_str_to_int("10:20")).to eq(620)
    expect(Duration.duration_str_to_int("01:00")).to eq(60)
  end

end