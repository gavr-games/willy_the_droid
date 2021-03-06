require 'minigl'
require_relative 'game'
require_relative 'constants'

class Window < MiniGL::GameWindow
  include MiniGL

  def initialize
    super(SCREEN_WIDTH, SCREEN_HEIGHT, FULL_SCREEN)
    G.kb_held_delay = 5
    self.caption = 'Data The Android'

    Res.prefix = File.expand_path(__FILE__).split('/')[..-3].join('/') + '/data'
    Game.initialize
  end

  def needs_cursor?
    true
  end


  def update
    KB.update
    Mouse.update
    Game.update
  end

  def draw
    Game.draw
  end
end

Window.new.show
