require "minitest/autorun"
require_relative "../lib/board"
require_relative "../lib/jewel"
require_relative "../lib/coordinate"

describe "Board" do

  let(:board) { Board.new(5,6) }

  it "has correct number of rows and columns" do
    board.cells.length.must_equal 5
    board.cells.values.each do |col|
      col.length.must_equal 6
    end
  end

  it "can place jewel at a location on board" do
    jewel = Jewel.new(1)
    coor = Coordinate.new(0,0)
    board[coor] = jewel
    board[coor].must_equal jewel
  end

  it "can swap position of 2 jewels" do
    jewel1 = Jewel.new(0)
    jewel2 = Jewel.new(1)

    coor1 = Coordinate.new(0,0)
    coor2 = Coordinate.new(0,1)
    board[coor1] = jewel1
    board[coor2] = jewel2
    board.swap(coor1, coor2)

    board[coor1].must_equal jewel2
    board[coor2].must_equal jewel1
  end

  it "can land jewels when the it is empty below" do
    jewel = Jewel.new(0)
    coor = Coordinate.new(0,0)
    board[coor] = jewel
    board.land_jewels

    board[coor].must_be_nil
    board[Coordinate.new(0,5)].must_equal jewel
  end

  describe "when there are connected jewels of the same color" do

    before do
      @jewels = []
      5.times { @jewels << Jewel.new(0) }
    end

    it "can reduce horizontally connected jewels" do
      board[Coordinate.new(0,5)] = @jewels.pop
      board[Coordinate.new(1,5)] = @jewels.pop
      board[Coordinate.new(2,5)] = @jewels.pop
      board[Coordinate.new(3,5)] = @jewels.pop

      board.reduce
      board.each_coordinate do |coor|
        board[coor].must_be_nil
      end
    end

    it "can reduce vertically connected jewels" do
      board[Coordinate.new(1,3)] = @jewels.pop
      board[Coordinate.new(1,4)] = @jewels.pop
      board[Coordinate.new(1,5)] = @jewels.pop

      board.reduce
      board.each_coordinate do |coor|
        board[coor].must_be_nil
      end
    end

    it "can reduce both horizontally and vertically connected jewels" do
      board[Coordinate.new(1,3)] = @jewels.pop
      board[Coordinate.new(1,4)] = @jewels.pop
      board[Coordinate.new(1,5)] = @jewels.pop
      board[Coordinate.new(0,5)] = @jewels.pop
      board[Coordinate.new(2,5)] = @jewels.pop

      board.reduce
      board.each_coordinate do |coor|
        board[coor].must_be_nil
      end
    end

    it "can reduce connected jewels after landing" do
      diff_color_jewels = []
      3.times { diff_color_jewels << Jewel.new(1) }

      board[Coordinate.new(0,5)] = @jewels.pop
      board[Coordinate.new(1,5)] = @jewels.pop
      board[Coordinate.new(2,5)] = @jewels.pop
      board[Coordinate.new(1,4)] = diff_color_jewels.pop
      board[Coordinate.new(2,4)] = diff_color_jewels.pop
      board[Coordinate.new(3,5)] = diff_color_jewels.pop

      board.reduce
      board.each_coordinate do |coor|
        board[coor].must_be_nil
      end
    end
  end

end
