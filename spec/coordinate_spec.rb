require "minitest/autorun"
require_relative "../lib/coordinate"

describe "Coordinate" do
  it "holds x and y position" do
    coor = Coordinate.new(0,1)
    coor.x.must_equal 0
    coor.y.must_equal 1
  end
end
