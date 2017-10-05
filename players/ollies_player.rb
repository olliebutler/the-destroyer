class OlliesPlayer
  def initialize
    @starting_used = []
    @attempts = []
    @coords_hit = []
    @previous_hits = 0
    @previous_ships_remaining = 5
    @hits_coordinates = []
    @point_of_interest = []
    @direction_of_ship = :unknown
    @previous_state = []
    @history = []
    @hunting = true
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



  def repeated_attempt(coordinate)
    @attempts.include?(coordinate)
  end

  def take_turn(state, ships_remaining)

    update_history(state)



    if @hunting == true && @history.last == :hit
      @hunting = false
      @point_of_interest = @attempts.last
      @direction_of_ship = :unknown
      attempt = destroy_mode
      @attempts << attempt
      return attempt
    elsif @hunting == true && @history.last == :miss
      attempt = hunt_mode
      @attempts << attempt
      return attempt
    elsif @hunting == false && last_attempt_destroyed_ship(ships_remaining) == false
      attempt = destroy_mode
      @attempts << attempt
      return attempt
    elsif @hunting == false && last_attempt_destroyed_ship(ships_remaining) == true
      @hunting = true
      @point_of_interest = []
      @direction_of_ship = :unknown
      attempt = hunt_mode
      @attempts << attempt
      return attempt
    end

  end

  def last_attempt_destroyed_ship(ships_remaining)
    if @previous_ships_remaining == ships_remaining.length
      return false
    else
      @previous_ships_remaining = ships_remaining.length
      return true
    end
  end

  def update_history(state)
    if count_hits(state) == count_hits(@previous_state)
      @history << :miss
    else
      @history << :hit
      @hits_coordinates << @attempts.last
    end
    @previous_state = state
  end

  def count_hits(state)
    counts = Hash.new 0
    state.each do |s|
      s.each do |r|
        counts[r] += 1
      end
    end
    return counts[:hit]
  end

  def count_misses(state)
    counts = Hash.new 0
    state.each do |s|
      s.each do |r|
        counts[r] += 1
      end
    end
    return counts[:miss]
  end

  def hunt_mode
    cheq_arr = chequered_array
    coordinate = cheq_arr.sample

    while repeated_attempt(coordinate)
      coordinate = cheq_arr.sample
    end
    return coordinate
  end

  def destroy_mode

    analyse_boat_direction

    if @direction_of_ship == :unknown
      return find_boat_direction
    else
      puts "attacking direction - #{@direction_of_ship}"
      return attack_direction
    end

  end

  def attack_direction

    case @direction_of_ship
    when :across
      attack_across
    when :vertical
      attack_vertical
    end

  end

  def attack_across

    surrounding = surrounding_coords(@point_of_interest)
    left = surrounding[3]
    right = surrounding[1]

    cal = can_attack_left(left)

    if !cal.empty?
      return cal
    end

    car = can_attack_right(right)

    if !car.empty?
      return car
    end

    # if can_attack_left(left)
    #   surrounding = surrounding_coords(@point_of_interest)
    #   left = surrounding[3]
    #   return attack_left(left)
    # end

    # if can_attack_right(right)
    #   surrounding = surrounding_coords(@point_of_interest)
    #   right = surrounding[1]
    #   return attack_right(right)
    # end

    attack_vertical

  end

  #  def attack_left(left)
  #    while was_attempt_hit(left)
  #      left[0] -= 1
  #    end
  #    return left
  #  end

  def can_attack_left(left)
    while was_attempt_hit(left)
      left[0] -= 1
    end

    if !has_coordinate_been_attempted(left)
    # return "left" to take turn
      return left
    else
      return []
    end
  end

  def can_attack_right(right)
    while was_attempt_hit(right)
      right[0] += 1
    end
    if !has_coordinate_been_attempted(right)
      return right
    else
      return []
    end
  end

  # def attack_right(right)
  #   while was_attempt_hit(right)
  #     left[0] += 1
  #   end
  #   return right
  # end

  def attack_vertical
    surrounding = surrounding_coords(@point_of_interest)
    up = surrounding[0]
    down = surrounding[2]

    if can_attack_up(up)
      surrounding = surrounding_coords(@point_of_interest)
      up = surrounding[0]
      return attack_up(up)
    end

    if can_attack_down(down)
      surrounding = surrounding_coords(@point_of_interest)
      down = surrounding[2]
      return attack_down(down)
    end
  end

  def can_attack_up(up)
    while was_attempt_hit(up)
      up[1] += 1
      end

    if !has_coordinate_been_attempted(up)
      return true
    else
      return false
    end
  end

  def attack_up(up)
    while was_attempt_hit(up)
      up[1] += 1
    end
    return up
  end

  def can_attack_down(down)
    while was_attempt_hit(down)
      down[1] -= 1
      end

    if !has_coordinate_been_attempted(down)
      return true
    else
      return false
    end
  end

  def attack_down(down)
    while was_attempt_hit(down)
      down[1] -= 1
    end
    return down
  end

  def analyse_boat_direction
    surroundings = surrounding_coords(@point_of_interest)

    #right
    if was_attempt_hit(surroundings[1])
      @direction_of_ship = :across
    end
    #down
    if was_attempt_hit(surroundings[2])
      @direction_of_ship = :vertical
    end
    #left
    if was_attempt_hit(surroundings[3])
      @direction_of_ship = :across
    end
    #up
    if was_attempt_hit(surroundings[0])
      @direction_of_ship = :vertical
    end

  end

  def has_coordinate_been_attempted(coord)

    if @attempts.include?(coord)
      return true
    else
      return false
    end

  end

  def was_attempt_hit(coord)
    if has_coordinate_been_attempted(coord)
      index = @attempts.find_index(coord)
      result = @history[index]
      if result == :hit
        return true
      else
        return false
      end
    else
      return false
    end
  end


  def find_boat_direction

    surrounding_coords = surrounding_coords(@point_of_interest)
    surrounding_coords.each do |x|

      if valid_coord(x) && (has_coordinate_been_attempted(x) == false)
        return x
      end
    end

  end


  def surrounding_coords(coord)
    puts "finding surroundings for #{coord}"
    up = []
    up[0] = coord[0]
    up[1] = coord[1]+1
    puts "found up - #{up}"
    down = []
    down[0] = coord[0]
    down[1] = coord[1]-1
    puts "found down - #{down}"
    right = []
    right[0] = coord[0]+1
    right[1] = coord[1]
    puts "found right - #{right}"
    left = []
    left[0] = coord[0]-1
    left[1] = coord[1]
    puts "found left - #{left}"
    [up,right,down,left]
  end

  def valid_coord(coord)
    if coord[0] < 10 && coord[1] < 10
      return true
    else
      false
    end
  end
end
