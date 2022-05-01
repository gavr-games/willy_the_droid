require 'minigl'

include MiniGL

class Matter < Sprite
  attr_reader :x_cell, :y_cell, :state

  def initialize(x_cell, y_cell, state = :empty)
    @x_cell = x_cell
    @y_cell = y_cell
    @x = real_x(@x_cell)
    @y = real_y(@y_cell)
    @state = state
    super(@x, @y, :sprite_matter, 3, 1)
  end

  def update
    case @state
    when :matter
      animate [0], 1
    when :antimatter
      animate [2], 1
    else
      animate [1], 1
    end
  end

  def pickup
    @state = :empty
  end

  def set_state(state)
    @state = state
  end

  def to_h
    {
      x: @x_cell,
      y: @y_cell,
      state: @state
    }
  end

  private

  def real_x(x_cell)
    CELL_SIZE * 3 / 2 + x_cell * CELL_SIZE - 8
  end

  def real_y(y_cell)
    CELL_SIZE + y_cell * CELL_SIZE + 10
  end
end