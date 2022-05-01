require 'minigl'
require_relative 'ui/common_button'

include MiniGL

class Menu
  def initialize
    @bg = Res.img(:menu)
    Game.play_song(:theme)
    @title = Label.new(170, 150, Res.font(:pilotcommand, 64), TITLE, 0xffffff)
    @btns = [
      CommonButton.new(y: 400, text: "Play") do
        Game.set_state(:loading)
      end,
      CommonButton.new(y: 550, text: "Quit") do
        G.window.close
      end
    ]
    @btn_index = 0
  end

  def update
    if Game.key_press?(:confirm) || KB.key_pressed?(Gosu::KB_RETURN)
      @btns[@btn_index].click
    elsif Game.key_press?(:up, true)
      @btn_index -= 1
      @btn_index = @btns.size - 1 if @btn_index < 0
    elsif Game.key_press?(:down, true)
      @btn_index += 1
      @btn_index = 0 if @btn_index >= @btns.size
    end
    @btns.each(&:update)
  end

  def draw
    @bg.draw(0, 0, 0)
    @title.draw

    @btns.each_with_index do |b, i|
      b.draw
      #b.highlight.draw(b.x - 2, b.y - 2, 1) if i == @btn_index
    end
  end
end
