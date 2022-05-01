require 'minigl'

include MiniGL

class Teleport < Sprite
  attr_reader :x_cell, :y_cell, :state

  def initialize(x_cell, y_cell, state = :idle)
    @x_cell = x_cell
    @y_cell = y_cell
    @x = real_x(@x_cell)
    @y = real_y(@y_cell)
    @state = state
    super(@x, @y, :sprite_teleport, 4, 4)
  end

  def update
    case @state
    when :idle
      animate [4, 5], 30
    else
      animate [12, 13, 14, 15], 15
    end
  end

  def set_state(state)
    @state = state
  end

  private

  def real_x(x_cell)
    CELL_SIZE + x_cell * CELL_SIZE + 3
  end

  def real_y(y_cell)
    CELL_SIZE / 2 + y_cell * CELL_SIZE
  end
end