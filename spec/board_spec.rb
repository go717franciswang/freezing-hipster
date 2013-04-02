require "minitest/autorun"
require_relative "../lib/board"
require_relative "../lib/jewel"
require_relative "../lib/coordinate"
require_relative "../lib/board_stringer"

describe "Board" do

  let(:board) { Board.new(5,6).extend BoardStringer }

  it "has correct number of rows and columns" do
    board.cells.length.must_equal 5
    board.cells.values.each do |col|
      col.length.must_equal 6
    end
  end

  it "should place jewel at a location on board" do
    jewel = Jewel.new(1)
    coor = Coordinate.new(0,0)
    board[coor] = jewel
    board[coor].must_equal jewel
  end

  it "should swap position of 2 jewels" do
    empty_board = board.clone
    board.load('BR')

    board.swap(Coordinate.new(0,5), Coordinate.new(1,5))
    board.must_equal empty_board.load('RB')
  end

  it "should land jewels when the it is empty below" do
    empty_board = board.clone
    board.load('O
                _
                _')

    board.land_jewels
    board.must_equal empty_board.load('O')
  end

  describe "when there are connected jewels of the same color" do

    before do
      @jewels = []
      5.times { @jewels << Jewel.new(0) }
    end

    it "should reduce horizontally connected jewels" do
      board.load('OOO')

      board.reduce
      board.get_empty_count.must_equal 5 * 6
    end

    it "should reduce vertically connected jewels" do
      board.load('O
                  O
                  O')

      board.reduce
      board.get_empty_count.must_equal 5 * 6
    end

    it "should reduce both horizontally and vertically connected jewels" do
      board.load('_O
                  _O
                  OOO')

      board.reduce
      board.get_empty_count.must_equal 5 * 6
    end

    it "should reduce connected jewels after landing" do
      board.load('_RR
                  BBBR')

      board.reduce
      board.get_empty_count.must_equal 5 * 6
    end

    it "should reduce 4 jewels to 1 power jewel" do
      board.load('OOOO')

      board.reduce
      board.get_empty_count.must_equal 5 * 6 - 1
      board[Coordinate.new(1,5)].type.must_equal :power
    end

    it "should reduce 5 jewels to 1 hyper jewel in the middle" do
      board.load('OOOOO')

      board.reduce
      board.get_empty_count.must_equal 5 * 6 - 1
      board[Coordinate.new(2,5)].type.must_equal :hyper
    end
  end

  it "should return count of empty slots" do
    board.load('OO')
    board.get_empty_count.must_equal 5 * 6 - 2
  end
end
