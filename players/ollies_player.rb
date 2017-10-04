class OlliesPlayer
  def initialize
    @starting_used = []
    @attempts = []
  end

  def name
    "Ollies Player"
  end

  def new_game
  # @starting_used = []
  # positions = []
  # ship_sizes = [5,4,3,3,2]
  # ship_sizes.each { |size|  positions << calculate_valid_start_position(size)}
  # puts positions

  positions = [
    [0, 0, 5, :across],
    [0, 1, 4, :across],
    [0, 2, 3, :across],
    [0, 3, 3, :across],
    [0, 4, 2, :across]
    ]

  return positions
  end

  def chequered_array
    arr = []
    0.upto(9).each do |x|
      0.upto(9).each do |y|
        if x%2 == 0
          if y%2 != 0
          arr << [x,y]
        end
      else
        if y%2 == 0
          arr << [x,y]
        end
      end
    end
  end
  return arr
  end
  #
  # def calculate_valid_start_position(size)
  #   position = calculate_start_position(size)
  #
  #   while position == nil
  #     position = calculate_start_position(size)
  #   end
  #   return position
  # end
  #
  # def calculate_start_position(size)
  #
  #   orientation = across_or_down_rand
  #   coordinates = rand_coordinate
  #
  #   if not_valid_position(size, coordinates, orientation)
  #     valid = calculate_start_position(size)
  #     return nil
  #   end
  #
  #   @starting_used.concat(calculate_surrondings(coordinates,size,orientation))
  #
  #   return [coordinates[0], coordinates[1], size, orientation]
  # end
  #
  # def not_valid_position(size, coordinates, orientation)
  #
  #   unless (@starting_used & calc_full_coordinates(coordinates, size,orientation)).empty?
  #     return true
  #   end
  #
  #   if (orientation == :across) && (coordinates[0]+size > 9)
  #     return true
  #
  #   elsif (orientation == :down) && (coordinates[1]+size > 9)
  #     return true
  #   end
  #
  #   return false
  #
  # end
  #
  # def calc_full_coordinates(start,size,orientation)
  #   full_coordinates = []
  #
  #   if orientation == :across
  #
  #     start[0].upto(start[0]+size-1) { |i|
  #       coord = []
  #       coord[0] = i
  #       coord[1] = start[1]
  #       full_coordinates << coord
  #     }
  #   else
  #
  #     start[1].upto(start[1]+size-1) { |i|
  #       coord = []
  #       coord[1] = i
  #       coord[0] = start[0]
  #       full_coordinates << coord
  #     }
  #   end
  #   return full_coordinates
  # end
  #
  #
  # def calculate_surrondings(coord, size, orientation)
  #
  #   if orientation == :across
  #     @starting_used.concat(calc_full_coordinates([coord[0],coord[1]-1],size-1,orientation))
  #     @starting_used.concat(calc_full_coordinates([coord[0]-1,coord[1]],size+1,orientation))
  #     @starting_used.concat(calc_full_coordinates([coord[0],coord[1]+1],(size-1),orientation))
  #     return @starting_used
  #   else
  #     @starting_used.concat(calc_full_coordinates([coord[0]-1,coord[1]],size-1,orientation))
  #     @starting_used.concat(calc_full_coordinates([coord[0],coord[1]-1],size+1,orientation))
  #     @starting_used.concat(calc_full_coordinates([coord[0]+1,coord[1]],(size-1),orientation))
  #     return @starting_used
  #   end
  #
  # end
  #
  # def rand_coordinate
  #    [rand(10), rand(10)]
  #
  # end
  #
  # def across_or_down_rand
  #    rand(2) == 1 ? :across : :down
  #
  # end

  def repeated_attempt(coordinate)
    @attempts.include?(coordinate)
  end

  def take_turn(state, ships_remaining)
    cheq_arr = chequered_array
    coordinate = cheq_arr.sample
    puts "coordinate #{coordinate}"

    while repeated_attempt(coordinate)
      coordinate = cheq_arr.sample
      puts "coordinate in loops #{coordinate}"
    end

    return coordinate
  end


end
