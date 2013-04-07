#!/usr/bin/ruby 

require "set"
require_relative "./coordinate"

class Board
  attr_accessor :cells, :score, :base_point, :columns, :rows

  def initialize(cols, rows)
    @columns = cols
    @rows = rows
    @score = 0
    reset_base_point
    create_fresh_board
  end

  def reset_base_point
    @base_point = 10
  end

  def initialize_copy(other)
    self.create_fresh_board
    self.each_coordinate do |coor|
      if other[coor]
        self[coor] = other[coor].clone
      end
    end
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

  def hash
    jewels = []
    self.each_coordinate do |coor|
      jewels << self[coor]
    end
    jewels.hash
  end

  def eql?(other)
    self.hash == other.hash
  end

  def [](coordinate)
    if coordinate and self.within_board(coordinate)
      @cells[coordinate.x][coordinate.y]
    end
  end

  def []=(coordinate, jewel)
    self.place(coordinate, jewel)
  end

  def place(coordinate, jewel)
    @cells[coordinate.x][coordinate.y] = jewel
  end

  def swap(coor1, coor2)
    self[coor1], self[coor2] = self[coor2], self[coor1]
    if self[coor1]
      self[coor1].moved = true
    end
    if self[coor2]
      self[coor2].moved = true
    end
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

  def reduce_by_hyper_jewel(hyper_jewel_coor, dx, dy)
    if dx.abs + dy.abs != 1
      raise "Invalid offset: (#{dx}, #{dy})"
    end

    if self[hyper_jewel_coor].type != :hyper
      raise "Jewel at coordinate (#{dx}, #{dy}) is not a hyper jewel"
    end

    remove_set = Set.new
    linked_jewel = self[hyper_jewel_coor.dxy(dx, dy)]
    @score += 75
    remove_set << hyper_jewel_coor
    self.each_coordinate do |coor|
      jewel = self[coor]
      if jewel == linked_jewel
        if jewel.type == :power
          @score += 60
        else
          @score += 20
        end
        remove_set << coor
      end
    end

    @base_point += 10
    self.remove_jewels remove_set
    self.reduce
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
          if self[coor].type == :power
            self.trigger_power_explosion(coor, explode_set)
          end
        end

        case connected_range.length
        when 3
          @score += @base_point
        when 4
          @score += @base_point + 10
          if self[connected_range[1]].moved
            new_power_jewel_coor = connected_range[1]
          else
            new_power_jewel_coor = connected_range[2]
          end
          self[new_power_jewel_coor].type = :power
          keep_set << new_power_jewel_coor
        when 5
          @score += @base_point + 20
          new_hyper_jewel_coor = connected_range[2]
          self[new_hyper_jewel_coor].type = :hyper
          keep_set << new_hyper_jewel_coor
        else
          raise "Cannot handle #{connected_range.length} connected jewels"
        end

        @base_point += 10
      end

      self.remove_jewels remove_set.subtract(keep_set).merge(explode_set)
      self.set_all_jewels_not_moved
      self.reduce
    end
  end

  def set_all_jewels_not_moved
    self.each_coordinate do |coor|
      if self[coor] and self[coor].moved
        self[coor].moved = false
      end
    end
  end

  def trigger_power_explosion(coor, explode_set)
    @score += 20
    explode_set << coor
    coor.each_surrounding do |surrounding_coor|
      if self.within_board(surrounding_coor)
        unless explode_set.include?(surrounding_coor)
          if self[surrounding_coor] and self[surrounding_coor].type == :power
            self.trigger_power_explosion(surrounding_coor, explode_set)
          else
            explode_set << surrounding_coor
          end
        end
      end
    end
  end

  def within_board(coor)
    coor.x < @columns and coor.y < @rows
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

  def each_valid_move
    self.each_coordinate do |coor|
      if self[coor] and self[coor].type == :hyper
        distinct_jewel_coor = {}
        coor.each_neighbor do |neighbor|
          if self[neighbor]
            distinct_jewel_coor[self[neighbor].color] = neighbor
          end
        end
        distinct_jewel_coor.values.each do |neighbor|
          yield [coor, neighbor]
        end
      else
        coor.each_pattern do |pattern|
          c1, c2, c3 = pattern
          if self.valid_pattern?(pattern)
            if c2.x == c3.x
              yield [c1, c1.dx(c2.x - c1.x)]
            else
              yield [c1, c1.dy(c2.y - c1.y)]
            end
          end
        end
      end
    end
  end

  def valid_pattern?(pattern)
    c1, c2, c3 = pattern
    if self[c1].nil? or self[c2].nil? or self[c3].nil?
      false
    else
      self[c1] == self[c2] and self[c2] == self[c3]
    end
  end
end
