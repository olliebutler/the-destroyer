class LessNaivePlayer
  def initialize
    @plays = 10.times.map { |x| 10.times.map { |y| [x, y] } }.flatten(1)
  end

  def name
    "Slightly Less Naive Player"
  end

  def new_game
    [
      [0, 5, 5, :down],
      [1, 5, 4, :down],
      [2, 5, 3, :down],
      [6, 5, 3, :down],
      [8, 5, 2, :down]
    ]
  end

  def take_turn(state, ships_remaining)
    @plays.delete_at(rand(@plays.length))
  end
end
