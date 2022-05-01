require 'minigl'

include MiniGL

class Loading
  def initialize
    @bg = Res.img(:menu)
    @vehicle = Sprite.new 330, 440, :sprite_vehicle, 2, 2
    @start_time = Time.now.to_i
  end

  def update
    @vehicle.animate [0, 1, 2], 8
    Game.set_state(:level) if Time.now.to_i - @start_time > 3
  end

  def draw
    @bg.draw(0, 0, 0)
    @vehicle.draw
  end
end
