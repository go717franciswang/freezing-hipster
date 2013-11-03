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

  def ===(jewel)
    self.==(jewel) and @type == jewel.type
  end

  def to_s
    if @type == :power
      @color.to_s
    elsif @type == :hyper
      'H'
    else
      @color.to_s.upcase
    end
  end
end
