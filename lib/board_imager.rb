require_relative "./jewel"
require_relative "./coordinate"
require "gtk2"

module BoardImager

  def load_screen(x, y, w, h)
    pixbuf = Gdk::Pixbuf.from_drawable(
      nil, Gdk::Window.default_root_window, x, y, w, h, nil, 0, 0
    )
    self.load(pixbuf)
  end

  def load_file(filepath)
    pixbuf = Gdk::Pixbuf.new(filepath)
    self.load(pixbuf)
  end

  def load(pixbuf)
    cell_width = pixbuf.width / @columns
    cell_height = pixbuf.height / @rows
    center_x = (cell_width / 2).to_i
    center_y = (cell_height / 2).to_i
    pixel_byte_count = pixbuf.rowstride / pixbuf.width

    cell_pixel_samples = {}
    y = -1
    pixbuf.pixels.bytes.each_slice(pixbuf.rowstride) do |row|
      y += 1
      row_count = (y / cell_height).to_i
      offset_y = (y - row_count * cell_height - center_y + 4).abs
      unless offset_y % 3 == 0 and offset_y < 10 and row_count < @rows
        next
      end
      x = -1

      row.each_slice(pixel_byte_count) do |pixel_bytes|
        x += 1
        col_count = (x / cell_width).to_i
        offset_x = (x - col_count * cell_width - center_x).abs

        if offset_x % 3 == 0 and offset_x < 10 and col_count < @columns
          cell_pixel_samples[col_count] ||= {}
          cell_pixel_samples[col_count][row_count] ||= []
          cell_pixel_samples[col_count][row_count] << pixel_bytes[0...3]
        end
      end
    end

    cell_pixel_samples.each_pair do |col_count, row_pixel_samples|
      row_pixel_samples.each_pair do |row_count, pixel_samples|

        color_count = {}
        pixel_samples.each do |rgb|
          color = self.rgb2color(*rgb)
          if color
            color_count[color] ||= 0
            color_count[color] += 1
          end
        end

        unless color_count.empty?
          best_color = nil
          highest_count = 0
          color_count.each_pair do |color, count|
            if count > highest_count
              best_color = color
              highest_count = count
            end
          end
          self[Coordinate.new(col_count, row_count)] = Jewel.new(best_color)
        end
      end
    end
  end

  def rgb2color(r, g, b)
    color_dist = {}

    [[251, 23 , 52 , :R],
     [2  , 123, 247, :B],
     [254, 114, 6  , :O],
     [0  , 225, 21 , :G],
     [251, 253, 250, :W],
     [254, 238, 24 , :Y],
     [225, 2  , 226, :P]].each do |map|
      sr, sg, sb, color = map
      color_dist[color] = self.distance([r,g,b], [sr,sg,sb])
    end
    
    best_color = nil
    lowest_dist = 50
    color_dist.each_pair do |color, dist|
      if dist < lowest_dist
        best_color = color
        lowest_dist = dist
      end
    end
    return best_color
  end

  def distance(a, b)
    ((a[0] - b[0])**2 + (a[1] - b[1])**2 + (a[2] - b[2])**2)**0.5
  end
end
