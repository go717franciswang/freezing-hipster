class Jewel
  attr_accessor :color, :type, :moving

  def initialize(color, type=nil)
    @color = color
    @type = type # can be nil, :power, or :hyper
  end

  def ==(jewel)
    if jewel
      @color == jewel.color or @type == :hyper
    else
      false
    end
  end
end
