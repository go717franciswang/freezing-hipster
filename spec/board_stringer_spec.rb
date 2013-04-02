require "minitest/autorun"
require_relative "../lib/board"
require_relative "../lib/board_stringer"

describe "BoardString" do
  let(:board) { Board.new(5,6).extend BoardStringer }

  it "transform string into a board at the bottom" do
    board.load("BR
                GY")
    board[Coordinate.new(0,4)].color.must_equal :B
    board[Coordinate.new(1,4)].color.must_equal :R
    board[Coordinate.new(0,5)].color.must_equal :G
    board[Coordinate.new(1,5)].color.must_equal :Y
  end
end
