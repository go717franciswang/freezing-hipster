require "minitest/autorun"
require_relative "../lib/board"
require_relative "../lib/board_imager"
require_relative "../lib/board_stringer"

describe "BoardImager" do

  let(:board_img) { Board.new(8,2).extend BoardImager }
  let(:board_str) { Board.new(8,2).extend BoardStringer }
  let(:img_dir) { File.join(File.dirname(__FILE__), 'images') }

  it "should read an image without special jewels" do
    board_img.load_file(File.join(img_dir, '1.png'))
    board_str.load('RBOGWPOR
                    PRGPBROB')
    board_img.must_equal board_str
  end

  it "should read an image with blue power jewel" do
    board_img.load_file(File.join(img_dir, '3.png'))
    board_str.load('YGPBPRWY
                    RORWYBGP')
    board_str[Coordinate.new(5,1)].type = :power

    board_img.must_equal board_str
  end
end
