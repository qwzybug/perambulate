#
# A simple piano keyboard widget.
# This helps it work on OS X: http://vimeo.com/1503168
# I heard a rumor Windows Vista plays piano on its own.
# 

Shoes.setup do
  gem 'midiator'
end
require 'midiator'

class Piano < Widget
  def initialize opts = {}, &action
    opts = {:width => 700, :height => 100}.merge opts
    @action = action
    
    key_width = opts[:width] / 52.0
    ivory = {:bottom => 0, :width => key_width.round, :height => opts[:height] * 2 / 5}
    ebony = {:top => 0, :width => (key_width * 2 / 3).round, :height => opts[:height] * 3 / 5}
    
    last_x = -key_width
    stack(opts) {
      background white; stroke black
      (21..109).each do |note|
        x = last_x.round
        if [0, 2, 4, 5, 7, 9, 11].include? note % 12
          last_x += key_width
          midi_button ivory.merge(:left => x), gray(0,0), note
          line x, 0, x, opts[:height]
        else
          midi_button ebony.merge(:left => x + ebony[:width]), black, note
        end
      end
    }
    @midi = MIDIator::Interface.new
    @midi.autodetect_driver
  end
  def play note
    @midi.play(note, 0.1, 2, 100)
    @action.call(note) if @action
  end
  def midi_button rect, color, note
    stack(rect) { background color; click { play note } }
  end
end

Shoes.app :title => 'Piano', :width => 700, :height => 100 do
  piano {|note| info "That's a beautiful #{note}"}
end
