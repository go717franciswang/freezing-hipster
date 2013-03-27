require "minitest/autorun"
require_relative "../lib/jewel"

describe "Jewel" do

  let(:jewel) { Jewel.new(2) }

  it "has a color index" do
    jewel.color.must_equal 2
  end
end
