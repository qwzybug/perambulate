require 'yaml'

Playlist = YAML.load_file 'playlist.yaml'

class Jukebox
  @@current = nil
  def self.pause
    @@current.pause if @@current
  end
  def self.play
    @@current.play
  end
  def self.stop
    @@current.stop
    @@current.remove
    @@current = nil
  end
  def self.load filename
    stop if @@current
    @@current = $app.video(filename, :width => 0, :height => 0)
    $app.timer(1) { play } # videos don't seem to want to play right away
  end
end

$app = Shoes.app :title => Playlist['title'], :width => 600, :height => 600 do
  background silver..white
  stack(:margin => 10) {
    tagline Playlist['title'], :font => 'Helvetica'
    para Playlist['description'], :font => 'Helvetica italic 13px' if Playlist['description']
    Playlist['songs'].each do |song|
      flow {
        para song['preamble'] if song['preamble']
        if song['name'] and song['file']
          para link(song['name']) { Jukebox.load song['file'] }
        end
      }
      para song['postamble'], :font => 'Helvetica 13px' if song['postamble']
    end
    if Playlist['author']
      para "- #{Playlist['author']}", :font => 'Helvetica italic 12px',
                                      :margin => [5, 30, 0, 30]
    end
  }
end
