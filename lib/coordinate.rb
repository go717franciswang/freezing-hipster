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

  def dxy(delta_x, delta_y)
    Coordinate.new(@x + delta_x, @y + delta_y)
  end

  def each_surrounding
    [[-1,-1], [0,-1], [1,-1],
     [-1, 0],         [1, 0],
     [-1, 1], [0, 1], [1, 1]].each do |offset|
      yield self.dxy(*offset)
    end
  end

  def each_neighbor
    [       [0,-1],
     [-1,0],       [1,0],
            [0, 1]      ].each do |offset|
      yield self.dxy(*offset)
     end
  end

  def hash
    @x * 50 + @y
  end

  def eql?(coor)
    @x == coor.x and @y == coor.y
  end

  alias :== :eql?

  def each_pattern
    # first position in each pattern is always the one that need to be moved
    [
      [[0,0],[1,1],[2,1]],
      [[2,1],[0,0],[1,0]],
      [[0,0],[1,1],[1,2]],
      [[1,2],[0,0],[0,1]],
      [[0,1],[1,0],[1,2]],
      [[1,1],[0,0],[0,2]],
      [[1,1],[0,0],[2,0]],
      [[1,0],[0,1],[2,1]],
      [[0,1],[1,0],[2,0]],
      [[2,0],[0,1],[1,1]],
      [[1,0],[0,1],[0,2]],
      [[0,2],[1,0],[1,1]],
      [[3,0],[0,0],[1,0]],
      [[0,0],[2,0],[3,0]],
      [[0,0],[0,2],[0,3]],
      [[0,3],[0,0],[0,1]],
    ].each do |pattern|
      yield [self.dxy(*pattern[0]), self.dxy(*pattern[1]), self.dxy(*pattern[2])]
    end
  end
end
