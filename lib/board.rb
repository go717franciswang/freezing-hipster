#!/usr/bin/ruby 

require_relative "./coordinate"

class Board
  attr_accessor :cells

  def initialize(cols, rows)
    @columns = cols
    @rows = rows
    create_fresh_board
  end

  def create_fresh_board
    @cells = {}
    @columns.times do |c|
      @rows.times do |r|
        @cells[c] ||= {}
        @cells[c][r] = nil
      end
    end
  end

  def [](coordinate)
    @cells[coordinate.x][coordinate.y]
  end

  def []=(coordinate, jewel)
    self.place(coordinate, jewel)
  end

  def place(coordinate, jewel)
    @cells[coordinate.x][coordinate.y] = jewel
  end

  def swap(coordinate1, coordinate2)
    self[coordinate1], self[coordinate2] = self[coordinate2], self[coordinate1]
  end

  def land_jewels
    (0...@columns).each_with_index do |c|
      lowest_empty_row = nil
      (0...@rows).reverse_each do |r|
        if lowest_empty_row.nil? and @cells[c][r].nil?
          lowest_empty_row = r
        elsif lowest_empty_row and @cells[c][r]
          self.swap(Coordinate.new(c,r), Coordinate.new(c,lowest_empty_row))
          lowest_empty_row -= 1
        end
      end
    end
  end
end
