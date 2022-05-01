require 'minigl'

include MiniGL

class CommonButton < Button
  def initialize(y:, text:, &action)
    super(x: 350, y: y, font: Game.big_font, text: text, img: :button, center_x: true, center_y: true, &action)
    @text = text
    @action = lambda do |_|
      action.call
      Game.play_sound(:click)
    end
  end

  def draw(alpha = 255, z_index = 0, color = 0xffffff)
    super
  end
end