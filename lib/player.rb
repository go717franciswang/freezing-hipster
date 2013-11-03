require_relative "./solver"
require_relative "./board"
require_relative "./board_imager"

class Player
  attr_accessor :tl_x, :tl_y, :br_x, :br_y, :columns, :rows

  def initialize(tl_x, tl_y, br_x, br_y, columns, rows)
    @tl_x = tl_x
    @tl_y = tl_y
    @br_x = br_x
    @br_y = br_y

    @width = @br_x - @tl_x
    @height = @br_y - @tl_y

    @columns = columns
    @rows = rows

    @cell_width = @width / @columns
    @cell_height = @height / @rows

    @window = Gdk::Window.default_root_window
  end

  def play
    solver = Solver.new
    while true
      board = Board.new(@columns, @rows).extend BoardImager
      board.load_screen(@tl_x, @tl_y, @width, @height)

      move, score = solver.best_move(board)
      if move
        self.log(move, score)
        self.swap(*move)

        _, x, y, _= @window.pointer
        if y < 200 or y > @br_y
          puts "x: #{x}, #{@tl_x}, #{@br_x}, y: #{y}, #{@tl_y}, #{@br_y}"
          break
        end
      end
    end
  end

  def swap(coor1, coor2)
    from = self.pos(coor1)
    to = self.pos(coor2)

    cmd = "xdotool mousemove #{from[0]} #{from[1]} " +
          "click 1 sleep 0.25 " +
          "mousemove #{to[0]} #{to[1]} " +
          "click 1 sleep 0"
    IO.popen(cmd)
  end

  def pos(coor)
    [(@tl_x + @cell_width * (coor.x + 0.5)).to_i, 
     (@tl_y + @cell_height * (coor.y + 0.5)).to_i]
  end

  def log(move, score)
    from, to = move
    puts "moving from (#{from.x}, #{from.y}) to (#{to.x}, #{to.y}), expecting #{score} pts"
  end

  def distance(a, b)
    ((a[0] - b[0])**2 + (a[1] - b[1])**2)**0.5
      
  end
end
