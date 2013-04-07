class Jewel
  attr_accessor :color, :type, :moved

  def initialize(color, type=nil)
    @color = color
    @type = type # can be nil, :power, or :hyper
    @moved = false
  end

  def ==(jewel)
    if jewel
      @color == jewel.color and @type != :hyper
    else
      false
    end
  end
end
