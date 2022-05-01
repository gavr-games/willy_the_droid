require 'minigl'

include MiniGL

class Droid < Sprite
  attr_reader :x_cell, :y_cell, :state

  def initialize(x_cell, y_cell)
    @x_cell = x_cell
    @y_cell = y_cell
    @x = real_x(@x_cell)
    @y = real_y(@y_cell)
    @target_x = @x
    @target_y = @y
    @state = :idle
    @speech = nil
    super(@x, @y, :sprite_droid, 8, 8)
  end

  def update
    case @state
    when :walk
      animate [8, 9, 10, 11, 12, 13, 14, 15], 2
      if @target_x > @x
        @x = @x + MOVE_SPEED
        @x = @target_x if @x > @target_x
      end
      if @target_x < @x
        @x = @x - MOVE_SPEED
        @x = @target_x if @x < @target_x
      end
      if @target_y > @y
        @y = @y + MOVE_SPEED
        @y = @target_y if @y > @target_y
      end
      if @target_y < @y
        @y = @y - MOVE_SPEED
        @y = @target_y if @y < @target_y
      end
      # stop
      if @x == @target_x && @y == @target_y
        @state = :idle
      end
    when :dead
      animate_once [48, 49, 50, 51, 52, 53, 54, 55], 8
    else
      animate [0, 1, 2, 3, 4, 5, 6], 8
    end
  end

  def move(dir)
    if @state == :idle
      case dir
      when :up
        @y_cell = @y_cell - 1
      when :down
        @y_cell = @y_cell + 1
      when :left
        @x_cell = @x_cell - 1
      when :right
        @x_cell = @x_cell + 1
      end
      @state = :walk
      @speech = nil
      @speech_text = nil
      @target_x = real_x(@x_cell)
      @target_y = real_y(@y_cell)
    end
  end

  def draw
    if @speech
      @speech.draw(real_x(@x_cell) + CELL_SIZE / 2, real_y(@y_cell) - CELL_SIZE * 2 + 10)
      @speech_text.draw
    end
    super
  end

  def talk(text)
    @speech = Res.img(:speech)
    @speech_text = Label.new(real_x(@x_cell) + CELL_SIZE, real_y(@y_cell) - CELL_SIZE - 20, Res.font(:pilotcommand, 12), text , 0x000000)
  end

  def die
    @state = :dead
  end

  private

  def real_x(x_cell)
    CELL_SIZE + x_cell * CELL_SIZE
  end

  def real_y(y_cell)
    CELL_SIZE / 2 + 10 + y_cell * CELL_SIZE
  end
end