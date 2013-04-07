require "minitest/autorun"
require_relative "../lib/board"
require_relative "../lib/jewel"
require_relative "../lib/coordinate"
require_relative "../lib/board_stringer"
require_relative "../lib/solver"

describe "Solver" do

  let(:solver) { Solver.new }
  let(:board) { Board.new(5,6).extend BoardStringer }

  it "should return nil when there is no valid move" do
    board.load('OO')
    solver.best_move(board).must_be_nil
  end

  it "should return the move the generate the highest score" do
    board.load('__B
                _DB
                ABA
                FAB')
    solver.best_move(board).must_equal [[Coordinate.new(1,5), Coordinate.new(1,4)], 30]
  end

  it "should search for best move recursively" do
    board.load('A
                A
                BBCB
                ABBC
                BACC')
    solver.best_move(board).must_equal [[Coordinate.new(2,3), Coordinate.new(3,3)], 60]
  end

  it "should can handle hyper jewels" do
    board.load('AAB
                BBC')
    board[Coordinate.new(2,5)].type = :hyper
    solver.best_move(board).must_equal [[Coordinate.new(2,5), Coordinate.new(1,5)], 135]
  end
end
