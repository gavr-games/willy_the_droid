require 'minigl'
require_relative 'droid'
require_relative 'matter'
require_relative 'teleport'

include MiniGL

class Level
  def initialize
    @bg = Res.img(:level)
    @field = []
    @matters = []
    @droid = Droid.new(1,1)
    @droid.talk "I need to collect\nall matters\nand antimatters\nsources before\nship explodes..."
    @teleport = Teleport.new(TELEPORT_X, TELEPORT_Y)
    @moves_left = 0
    @counter = Res.img(:counter)
    @counter_label = Label.new(70, 5, Res.font(:pilotcommand, 36), @moves_left.to_s , 0xffffff)
    @current_matter = Matter.new(2, -1)
    init_field
    init_matters
    set_moves_left
  end

  def update
    if Game.key_press?(:up)
      if @droid.y_cell > 1 && can_move_to_teleport(@droid.x_cell, @droid.y_cell - 1)
        move_droid(:up)
      else
        Game.play_sound(:hit)
      end
    elsif Game.key_press?(:down)
      if @droid.y_cell < MAX_FIELD_SIZE - 2 && can_move_to_teleport(@droid.x_cell, @droid.y_cell + 1)
        move_droid(:down)
      else
        Game.play_sound(:hit)
      end
    elsif Game.key_press?(:left)
      if @droid.x_cell > 1 && can_move_to_teleport(@droid.x_cell - 1, @droid.y_cell)
        move_droid(:left)
      else
        Game.play_sound(:hit)
      end
    elsif Game.key_press?(:right)
      if @droid.x_cell < MAX_FIELD_SIZE - 2 && can_move_to_teleport(@droid.x_cell + 1, @droid.y_cell)
        move_droid(:right)
      else
        Game.play_sound(:hit)
      end
    elsif Game.key_press?(:quit)
      Game.set_state(:menu)
    end
    if @moves_left == 0
      if @droid.state != :dead
        @droid.die
        @droid.talk "Ship exploded...\nTry again!\nPress Esc"
        Game.play_sound(:loose)
      end
    else
      pickup_matter
      can_teleport
      finish_game
    end
    @teleport.update
    @droid.update
    @matters.each { |m| m.update }
    @current_matter.update
  end

  def draw
    @bg.draw(0, 0, 0)
    @counter.draw(50, 0, 0)
    @counter_label.draw
    MAX_FIELD_SIZE.times do |x|
      MAX_FIELD_SIZE.times do |y|
        @field[x][y].draw(CELL_SIZE + x * CELL_SIZE, CELL_SIZE + y * CELL_SIZE, 0)
      end
    end
    @teleport.draw
    @matters.each { |m| m.draw }
    @current_matter.draw
    @droid.draw
  end

  private

  def can_move_to_teleport(target_x, target_y)
    return false if @droid.state == :dead
    return false if @teleport.state != :ready && in_teleport(target_x, target_y)

    true
  end

  def move_droid(dir)
    @droid.move(dir)
    @moves_left = @moves_left - 1
    @counter_label.text = @moves_left.to_s
  end

  def pickup_matter
    matter = @matters.find { |m| m.state != :empty && m.x_cell == @droid.x_cell && m.y_cell == @droid.y_cell }
    return if matter == nil

    if @current_matter.state == matter.state
      @droid.talk "I have too many\n#{@current_matter.state.to_s}\nsources"
    else
      @current_matter.set_state(matter.state)
      matter.pickup
      Game.play_sound(:pickup)
    end
  end

  def can_teleport
    matters_left = @matters.count { |m| m.state != :empty }
    if matters_left == 0 && @teleport.state != :ready
      @droid.talk "Done!\nNo let's go to\nteleporter..."
      @teleport.set_state(:ready)
    end
  end

  def finish_game
    if @teleport.state == :ready && in_teleport(@droid.x_cell, @droid.y_cell) && @droid.state != :dead
      @droid.die
      @droid.talk "Nice job!\nWe did it!\nWe saved the ship!\nPress Esc"
      Game.play_sound(:win)
    end
  end

  def init_field
    MAX_FIELD_SIZE.times do |x|
      MAX_FIELD_SIZE.times do |y|
        @field[x] = [] if @field[x] == nil
        field_max = MAX_FIELD_SIZE - 1
        tile_name = case {x: x, y: y}
          in {x: 0, y: 0}
            "cornertl"
          in {x: ^field_max, y: ^field_max}
            "cornerbr"
          in {x: 0, y: ^field_max}
            "cornerbl"
          in {x: ^field_max, y: 0}
            "cornertr"
          in {x: 0, y: _}
            "left"
          in {x: _, y: ^field_max}
            "bottom"
          in {x: _, y: 0}
            "top"
          in {x: ^field_max, y: _}
            "right"
          else
            "tile"
        end
        @field[x][y] = Res.img("floor_#{tile_name}".to_sym, false, true) # tile
      end
    end
  end

  def init_matters
    matter = nil
    DIFFICULTY.times do
      matter = matter == :matter ? :antimatter : :matter
      x, y = free_coord
      @matters << Matter.new(x, y, matter)
      matter = matter == :matter ? :antimatter : :matter
      x, y = free_coord
      @matters << Matter.new(x, y, matter)
    end
  end

  def in_teleport(x, y)
    teleport_coords = []
    TELEPORT_SIZE.times do |tx|
      TELEPORT_SIZE.times do |ty|
        teleport_coords << { x: TELEPORT_X + tx, y: TELEPORT_Y + ty }
      end
    end
    teleport_coords.find { |coords| x == coords[:x] && y == coords[:y] }
  end

  def free_coord
    x, y = rand(MAX_FIELD_SIZE - 2) + 1, rand(MAX_FIELD_SIZE - 2) + 1
    if (x == 1 && y == 1) || in_teleport(x, y)
      x, y = free_coord
    else
      @matters.each do |m|
        if x == m.x_cell && y == m.y_cell
          x, y = free_coord
        end
      end
    end
    return x, y
  end

  def set_moves_left
    @candidates = []
    matters = @matters.map { |m| m.to_h }
    moves_tree(@droid.x_cell, @droid.y_cell, :empty, matters, 0)
    @candidates = @candidates.sort.reverse.each_slice((@candidates.size / 2).to_i).to_a[0]
    @moves_left = (@candidates.sum(0.0) / @candidates.size).to_i
    @counter_label.text = @moves_left.to_s
  end

  def moves_tree(start_x, start_y, state, matters, current_moves)
    if  matters.size == 0
      moves_to_teleport = current_moves + (TELEPORT_X + 1 - start_x).abs + (TELEPORT_Y + 1 - start_y).abs
      @candidates << moves_to_teleport
      return
    end

    matters.each do |matter|
      if matter[:state] != state
        new_current_moves = current_moves + (matter[:x] - start_x).abs + (matter[:y] - start_y).abs
        new_matters = matters.select { |m| m[:x] != matter[:x] && m[:y] != matter[:y] }
        moves_tree(matter[:x], matter[:y], matter[:state], new_matters, new_current_moves)
      end
    end
  end
end
