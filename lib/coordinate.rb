class Coordinate
  attr_accessor :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def dx(delta)
    Coordinate.new(@x + delta, y)
  end

  def dy(delta)
    Coordinate.new(@x, @y + delta)
  end
end
