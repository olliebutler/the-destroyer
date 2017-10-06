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
    @current_state = Hash.new
    @array_of_interest = []
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

  def coordinate_array
    arr = []
    0.upto(9).each do |x|
      0.upto(9).each do |y|
        arr << [y,x]
      end
    end
    return arr
  end

  def state_to_array(state)
    arr = []
    state.each do |l|
      l.each do |m|
        arr << m
      end
    end
  return arr
  end

  def state_to_hash(state)

    state_array = state_to_array(state)
    coord_array = coordinate_array

    h = Hash.new

    coord_array.each_with_index do |v,i|
      h[v] = state_array[i]
    end

    @current_state = h
  end

  def take_turn(state, ships_remaining)

    update_history(state)
    state_to_hash(state)
    l_a_d_s = last_attempt_destroyed_ship(ships_remaining)

    puts @array_of_interest

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
    elsif @hunting == false && l_a_d_s == false
      attempt = destroy_mode
      @array_of_interest << @attempts.last
      @attempts << attempt
      return attempt
    elsif @hunting == false && l_a_d_s == true
      @hunting = true
      @point_of_interest = []
      @direction_of_ship = :unknown
      attempt = hunt_mode
      @attempts << attempt
      return attempt
    end

  end


  def hunt_mode
    cheq_arr = chequered_array
    coordinate = cheq_arr.sample
    i = 0
    while state_of_coordinate(coordinate) != :unknown
      coordinate = cheq_arr.sample
      if i > cheq_arr.length
        return random_hunt_mode
      end
      i+=1
    end
    return coordinate
  end

  def random_hunt_mode
    coordinate = coordinate_array.sample
    while state_of_coordinate(coordinate) != :unknown
      coordinate = coordinate_array.sample
    end
    return coordinate
  end

  def destroy_mode

    analyse_boat_direction

    if @direction_of_ship == :unknown
      return find_boat_direction
    else
      return attack_direction
    end

  end

  def attack_direction

    aa = attack_across
    av = attack_vertical

    case @direction_of_ship
    when :across
      if !aa.empty?
        return aa
      elsif !av.empty?
        return av
      end

    when :vertical
      if !av.empty?
        return av
      elsif !aa.empty?
        return aa
      end

    end

  end

  # def cycle_point_of_interest
  #
  #   i = 0
  #   while i < @array_of_interest.length
  #     @point_of_interest = @array_of_interest[i]
  #     if !av.empty?
  #       return av
  #     elsif !aa.empty?
  #       return aa
  #     end
  #     i+= 1
  #   end
  #   return hunt_mode
  # end

  def attack_across

    surrounding = surrounding_coords(@point_of_interest)
    left = surrounding[3]
    right = surrounding[1]

    #check if can attack coordinate to left of point of interest

    al = attack_left(left)

    if !al.empty?

      return al
    end

    #ceck if can loop back left

    lbl = loop_back_left(left)

    if !lbl.empty?

      return lbl
    end


    #check if can attack right of point of interest

    ar = attack_right(right)

    if !ar.empty?

      return ar
    end


    #check if can loop back right

    lbr = loop_back_right(right)

    if !lbr.empty?

      return lbr
    end

    attack_vertical

  end

  def attack_left(left)
    if state_of_coordinate(left) == :unknown
      return left
    else
      return []
    end
  end

  def attack_right(right)
    if state_of_coordinate(right) == :unknown
      return right
    else
      return []
    end
  end

  def loop_back_left(left)

    while true
      if valid_coord(left) == false
        return []
      end
      if state_of_coordinate(left) == :miss
        return []
      elsif state_of_coordinate(left) == :unknown
        return left
      else
        left[0] -= 1
      end
    end
  end

  def loop_back_right(right)
    puts "loop right"
    while true
      if valid_coord(right) == false
        return []
      end
      if state_of_coordinate(right) == :miss
        return []
      elsif state_of_coordinate(right) == :unknown
        return right
      else
        right[0] += 1
      end
    end
  end


  def attack_vertical
    surrounding = surrounding_coords(@point_of_interest)
    up = surrounding[0]
    down = surrounding[2]

    au = attack_up(up)

    if !au.empty?
      return au
    end

    lbu = loop_back_up(up)

    if !lbu.empty?
      return lbu
    end

    ad = attack_down(down)

    if !ad.empty?
      return ad
    end

    lbd = loop_back_down(down)

    if !lbd.empty?
      return lbd
    end


    attack_across

  end

  def attack_down(down)
    if state_of_coordinate(down) == :unknown
      return down
    else
      return []
    end
  end

  def attack_up(up)
    if state_of_coordinate(up) == :unknown
      return up
    else
      return []
    end
  end

  def loop_back_up(up)

    puts "loop up"

    while true
      puts up
      if valid_coord(up) == false
        return []
      end
      if state_of_coordinate(up) == :miss
        return []
      elsif state_of_coordinate(up) == :unknown
        return up
      else
        up[1] -= 1 #was +
      end

    end
  end

  def loop_back_down(down)
    puts "loop down"
    while true

      if valid_coord(down) == false
        return []
      end
      if state_of_coordinate(down) == :miss
        return []
      elsif state_of_coordinate(down) == :unknown
        return down
      else
        down[1] += 1 #was -
      end
    end
  end


  #########################################  Boat direction

  def analyse_boat_direction
    surroundings = surrounding_coords(@point_of_interest)


    #left or right
    if state_of_coordinate(surroundings[1]) == :hit || state_of_coordinate(surroundings[3]) == :hit
      @direction_of_ship = :across
    end
    #up or down
    if state_of_coordinate(surroundings[2]) == :hit || state_of_coordinate(surroundings[0]) == :hit
      @direction_of_ship = :vertical
    end

  end

  def find_boat_direction

    surrounding_coords = surrounding_coords(@point_of_interest)
    surrounding_coords.each do |x|

      if valid_coord(x) && (state_of_coordinate(x) == :unknown)
        return x
      end
    end

  end

  def surrounding_coords(coord)


    up = []
    up[0] = coord[0]
    up[1] = coord[1]-1

    down = []
    down[0] = coord[0]
    down[1] = coord[1]+1

    right = []
    right[0] = coord[0]+1
    right[1] = coord[1]

    left = []
    left[0] = coord[0]-1
    left[1] = coord[1]

    [up,right,down,left]
  end

  ############################################ HASH stuff and stuff that runs every go

  def state_of_coordinate(coord)
    @current_state[coord]
  end

  def was_hit(coord)

    if @current_state == :hit
      return true
    else
      return false
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

  def valid_coord(coord)
    if coord[0] < 10 && coord[1] < 10
      if coord[0] >= 0 && coord[1] >= 0
        return true
      else
        return false
      end
    else
      false
    end
  end
end
