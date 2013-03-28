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
    @cells[coordinate.x][coordinate.y] if coordinate
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

  def each_coordinate(vertical_first_traversal=true)
    if vertical_first_traversal
      (0...@columns).each_with_index do |c|
        (0...@rows).each_with_index do |r|
          yield Coordinate.new(c,r)
        end
      end
    else
      (0...@rows).each_with_index do |r|
        (0...@columns).each_with_index do |c|
          yield Coordinate.new(c,r)
        end
      end
    end
  end

  #TODO refactor this method to something more readable
  def reduce
    self.land_jewels
    connected_ranges = []
    connected_range = []

    self.each_coordinate do |coor|
      this_jewel = self[coor]
      last_jewel = self[connected_range.last]

      if last_jewel != this_jewel || self.bottom?(coor)
        if self.bottom?(coor) && this_jewel && this_jewel == last_jewel
          connected_range << coor
        end

        if connected_range.length >= 3
          connected_ranges += connected_range 
        end
        connected_range = []
      end
      connected_range << coor if this_jewel && !self.bottom?(coor)
    end

    self.each_coordinate(false) do |coor|
      this_jewel = self[coor]
      last_jewel = self[connected_range.last]

      if last_jewel != this_jewel || self.rightmost?(coor)
        if self.rightmost?(coor) && this_jewel && this_jewel == last_jewel
          connected_range << coor
        end

        if connected_range.length >= 3
          connected_ranges += connected_range 
        end
        connected_range = []
      end
      connected_range << coor if this_jewel && !self.rightmost?(coor)
    end

    unless connected_ranges.empty?
      self.remove_jewels connected_ranges
      self.reduce
    end
  end

  def bottom?(coor)
    coor.y == @rows - 1
  end

  def rightmost?(coor)
    coor.x == @columns - 1
  end

  def remove_jewels(coordinates)
    coordinates.each do |coor|
      self[coor] = nil
    end
  end
end
