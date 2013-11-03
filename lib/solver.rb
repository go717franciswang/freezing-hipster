#!/usr/bin/ruby 

require_relative "./board"

class Solver

  def initialize
    @board_best_score = {}
    @board_best_move = {}
  end

  def best_move(board, level=1, clear_cache=true)
    best = nil
    best_score = 0

    board.each_valid_move do |move|
      coor_from, coor_to = move
      # board_dup = Marshal.load(Marshal.dump(board))
      board_dup = board.clone

      if board_dup[coor_from].type == :hyper
        board_dup.reduce_by_hyper_jewel(
          coor_from, coor_to.x - coor_from.x, coor_to.y - coor_from.y
        )
      else
        board_dup.swap(coor_from, coor_to)
        board_dup.reduce
      end

      score = board_dup.score
      board_dup.score = 0

      if level > 0 and score > 0
        unless @board_best_score[board_dup]
          sub_best, sub_best_score = self.best_move(board_dup, level-1, false)
          @board_best_score[board_dup] = sub_best_score
          @board_best_move[board_dup] = sub_best
        end

        if @board_best_score[board_dup]
          score += @board_best_score[board_dup]
        end
      end

      if score > best_score
        best = move
        best_score = score
      end
    end

    if clear_cache
      @board_best_score = {}
      @board_best_move = {}
    end

    if best
      [best, best_score]
    else
      nil
    end
  end
end
