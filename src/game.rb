require 'minigl'
require_relative 'menu'
require_relative 'loading'
require_relative 'level'

class Game
  class << self
    include MiniGL

    attr_reader :font, :big_font

    def initialize
      @font = Res.font(:pilotcommand, 20)
      @big_font = Res.font(:pilotcommand, 32)
      set_state(:menu)
    end

    def update
      @controller.update
    end

    def draw
      @controller.draw
    end

    def play_song(id)
      song = Res.song(id)
      Gosu::Song.current_song&.stop unless Gosu::Song.current_song == song
      song.volume = MUSIC_VOLUME * 0.1
      song.play(true)
    end

    def play_sound(id)
      Res.sound(id).play(SOUND_VOLUME * 0.1)
    end

    def key_press?(id, held = false)
      keys = case id
             when :up
               [Gosu::KB_UP, Gosu::GP_0_UP]
             when :right
               [Gosu::KB_RIGHT, Gosu::GP_0_RIGHT]
             when :down
               [Gosu::KB_DOWN, Gosu::GP_0_DOWN]
             when :left
               [Gosu::KB_LEFT, Gosu::GP_0_LEFT]
             when :confirm
               [Gosu::KB_Q, Gosu::GP_0_BUTTON_0]
             when :cancel
               [Gosu::KB_W, Gosu::GP_0_BUTTON_1]
             when :undo
               [Gosu::KB_Z, Gosu::GP_0_BUTTON_2]
             when :restart
               [Gosu::KB_R, Gosu::GP_0_BUTTON_3]
             when :quit
               [Gosu::KB_ESCAPE, Gosu::GP_0_BUTTON_4]
             when :pause
               [Gosu::KB_SPACE, Gosu::GP_0_BUTTON_6]
             end
      keys.any? { |k| KB.key_pressed?(k) || held && KB.key_held?(k) }
    end

    def set_state(state)
      @state = state
      @controller = case @state
      when :loading
        Loading.new
      when :level
        Level.new
      else
        Menu.new
      end
    end
  end
end
