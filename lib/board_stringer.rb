require_relative "./jewel"
require_relative "./coordinate"

module BoardStringer
  def load(jewels_str)
    board_row_index = @rows - 1
    jewels_str.split("\n").reverse_each do |row|
      row.strip.chars.each_with_index do |char, board_col_index|
        coor = Coordinate.new(board_col_index, board_row_index)
        if char == '_'
          self[coor] = nil
        else
          self[coor] = Jewel.new(char.to_sym)
        end
      end
      board_row_index -= 1
    end
    self
  end
end
