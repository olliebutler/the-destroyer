class OlliesPlayer
  def initialize
    @attempts = []
    @previous_hits = 0
    @previous_ships_remaining = 5
    @point_of_interest = []
    @direction_of_ship = :unknown
    @previous_state = []
    @history = []
    @hunting = true
    @current_state = Hash.new
    @array_of_interest = []
    @size_of_ships = Hash.new
    @previous_size_of_ships = Hash.new

  end

  def name
    "Ollies Player"
  end

  def new_game


  positions = [
    [1, 3, 5, :down],
    [3, 6, 4, :across],
    [2, 1, 3, :down],
    [2, 5, 3, :down],
    [6, 4, 2, :across]
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
    @current_state.clear
    @current_state = h
  end

  def take_turn(state, ships_remaining)

    update_history(state)
    state_to_hash(state)



    case last_attempt_destroyed_ship(ships_remaining)
    when true
      size_of_kill = calculate_size_of_last_kill(ships_remaining)
      dead_coordinates = calculate_coordinates_of_last_kill(size_of_kill,@point_of_interest,@attempts.last)
      @array_of_interest = @array_of_interest - dead_coordinates
      if @array_of_interest.size > 0 #if we still have poi's
        @point_of_interest = @array_of_interest.sample
      else
        @hunting = true
      end

      case @hunting
      when true
        attempt = hunt_mode
        @attempts << attempt
        return attempt
      when false
        attempt = destroy_mode
        @attempts << attempt
        return attempt
      end

    when false

      case @hunting
      when true
        if @history.last == :hit
          @hunting = false
          @point_of_interest = @attempts.last
          @direction_of_ship = :unknown
          attempt = destroy_mode
          @attempts << attempt
          return attempt
        else
          attempt = hunt_mode
          @attempts << attempt
          return attempt
        end
      when false
        attempt = destroy_mode
        @attempts << attempt
        return attempt
      end

    end

  end

  def calculate_coordinates_of_last_kill(size,poi,last_hit)

    direction = calculate_kill_direction(poi, last_hit)

    case direction
    when :up
      arr = []
      0.upto(size-1).to_a.each do |i|
        arr[i] = [last_hit[0], last_hit[1] + i]
      end
      return arr
    when :down
      arr = []
      0.upto(size-1).to_a.each do |i|
        arr[i] = [last_hit[0],last_hit[1] - i]
      end
      return arr
    when :left
      arr = []
      0.upto(size-1).to_a.each do |i|
        arr[i] = [last_hit[0] - i, last_hit[1]]
      end
      return arr
    when :right
      arr = []
      0.upto(size-1).to_a.each do |i|
        arr[i] = [last_hit[0] + i, last_hit[1]]
      end
      return arr
    end

    return arr

  end

  def calculate_kill_direction(poi, last_hit)

    if poi[1] == last_hit[1]
      last_hit[0] - poi[0] < 0 ? :left : :right
    else
      last_hit[1] - poi[1] < 0 ? :up : :down
    end
  end

  def calculate_size_of_last_kill(ships_remaining)
    size_ships_remaining = count_ships(ships_remaining)
    size_ships_remaining.each do |k,v|
      if size_ships_remaining[k] != @previous_size_of_ships[k]
        return k
      end
    end
  end

  def count_ships(ships)


    h = Hash.new
    h = {5 => 0, 4 => 0, 3 => 0, 2 => 0}
    ships.each do |s|
        h[s] += 1
      end

    return h

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

    # case @direction_of_ship
    # when :across
    #   if !aa.empty?
    #     return aa
    #   elsif !av.empty?
    #     return av
    #   end
    #
    # when :vertical
    #   if !av.empty?
    #     return av
    #   elsif !aa.empty?
    #     return aa
    #   end
    # end

    case @direction_of_ship
    when :across
      if !Array(aa).empty?
        return aa
      elsif !Array(av).empty?
        return av
      end

    when :vertical
      if !Array(av).empty?
        return av
      elsif !Array(aa).empty?
        return aa
      end
    end

    @array_of_interest = @array_of_interest - [@point_of_interest]
    if @array_of_interest.size > 0
      @point_of_interest = @array_of_interest.sample
      destroy_mode
    else
      hunt_mode
    end


  end

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

    return []
    #attack_vertical


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

    return []
    #attack_across


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


    while true
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
      @array_of_interest << @attempts.last
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
