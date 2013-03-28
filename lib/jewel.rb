class Jewel
  attr_accessor :color

  def initialize(color)
    @color = color
  end

  def ==(jewel)
    if jewel
      @color == jewel.color
    else
      false
    end
  end
end
