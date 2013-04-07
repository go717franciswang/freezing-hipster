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

  it "should record jewel has been moved when it lands" do
    board.load('O
                _')
    board.land_jewels
    board[Coordinate.new(0,5)].moved.must_equal true
  end

  describe "reduce" do

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

    it "should reduce 4 jewels to 1 power jewel at the position of then inner moved jewel" do
      board.load('OOOO')
      board[Coordinate.new(2,5)].moved = true

      board.reduce
      board.get_empty_count.must_equal 5 * 6 - 1
      board[Coordinate.new(2,5)].type.must_equal :power
    end

    it "should reduce 5 jewels to 1 hyper jewel in the middle" do
      board.load('OOOOO')

      board.reduce
      board.get_empty_count.must_equal 5 * 6 - 1
      board[Coordinate.new(2,5)].type.must_equal :hyper
    end

    it "should cause explosion around the power jewel" do
      board.load('ABB
                  BBB
                  BAA')
      board[Coordinate.new(1,4)].type = :power
      board.reduce
      board.get_empty_count.must_equal 5 * 6
    end

    it "should cause explosion that trigger other explosion" do
      board.load('ABBA
                  BBBA
                  BAAB')
      board[Coordinate.new(1,4)].type = :power
      board[Coordinate.new(2,4)].type = :power
      board.reduce
      board.get_empty_count.must_equal 5 * 6
    end
  end

  describe "reduce by hyper jewel" do
    it "should remove all jewels of the same color on board" do
      board.load('HBRBB')
      hyper_jewel_coor = Coordinate.new(0,5)
      board[hyper_jewel_coor].type = :hyper
      board.reduce_by_hyper_jewel(hyper_jewel_coor, 1, 0)

      board.get_jewel_count(Jewel.new(:B)).must_equal 0
    end
  end

  describe "scoring" do
    it "should record 10 pt for a 3-jewel match" do
      board.load('OOO')
      board.reduce
      board.score.must_equal 10
    end

    it "should record 20 pt for a 4-jewel match" do
      board.load('OOOO')
      board.reduce
      board.score.must_equal 20
    end

    it "should record 30 pt for a 5-jewel match" do
      board.load('OOOOO')
      board.reduce
      board.score.must_equal 30
    end

    it "should increase base pt by 10 for each consecutive match" do
      board.load('_RR
                  BBBR')
      board.reduce
      board.score.must_equal 30
    end

    it "should record 30 pt for power jewel explosion" do
      board.load('OOO')
      board[Coordinate.new(1,5)].type = :power
      board.reduce
      board.score.must_equal 30
    end
  end

  it "should return count of empty slots" do
    board.load('OO')
    board.get_empty_count.must_equal 5 * 6 - 2
  end

  it "should return an iterator of valid moves" do
    board.load('O
                ROO')
    board.each_valid_move do |move|
      move.must_include(Coordinate.new(0,4), Coordinate.new(0,5))
    end
  end

  it "should return fixnum from hash method" do
    board.load('OOO')
    board.hash.must_be_instance_of Fixnum
  end
end
