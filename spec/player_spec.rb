require "minitest/autorun"
require_relative "../lib/player"
require_relative "../lib/board"
require_relative "../lib/coordinate"

describe "Player" do

  let(:player) { Player.new(50, 60, 200, 210, 8, 2) }
  let(:board) { Board.new(8,2) }

  it "should accept top-left and bottom-right position of game board" do
    player.tl_x.must_equal 50
    player.tl_y.must_equal 60
    player.br_x.must_equal 200
    player.br_y.must_equal 210
  end

  it "should accept column and row count" do
    player.columns.must_equal 8
    player.rows.must_equal 2
  end

  it "should compute the x,y position of a cell" do
    player.pos(Coordinate.new(0,0)).must_equal [50+150/16, 60+150/4]
  end
end
