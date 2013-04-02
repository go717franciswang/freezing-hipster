#!/usr/bin/ruby 

require "set"
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
          connected_ranges << connected_range 
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
          connected_ranges << connected_range 
        end
        connected_range = []
      end
      connected_range << coor if this_jewel && !self.rightmost?(coor)
    end

    unless connected_ranges.empty?
      remove_set = Set.new
      keep_set = Set.new
      explode_set = Set.new

      connected_ranges.each do |connected_range|
        remove_set.merge(connected_range)

        connected_range.each do |coor|
          case self[coor].type
          when :power
          when :hyper
          end
        end

        case connected_range.length
        when 3
        when 4
          #TODO find out which jewel becomes a power jewel
          new_power_jewel_coor = connected_range[1]
          self[new_power_jewel_coor].type = :power
          keep_set << new_power_jewel_coor
        when 5
          new_hyper_jewel_coor = connected_range[2]
          self[new_hyper_jewel_coor].type = :hyper
          keep_set << new_hyper_jewel_coor
        else
          raise "Cannot handle #{connected_range.length} connected jewels"
        end
      end

      self.remove_jewels remove_set.subtract(keep_set)
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

  def get_jewel_count(jewel)
    count = 0
    self.each_coordinate do |coor|
      if self[coor] == jewel
        count += 1
      end
    end
    count
  end

  def get_empty_count
    self.get_jewel_count(nil)
  end

  def ==(board2)
    self.each_coordinate do |coor|
      if self[coor] != board2[coor]
        return false
      end
    end
    true
  end
end
