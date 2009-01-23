require 'yaml'
require 'ftools'

Shoes.app :title => 'Playlister', :width => 600 do
  # horizontal rule
  def hr; stack(:width => -1, :height => 41, :margin => [0,20,0,20]) { background silver }; end
  # arg why can't I reopen classes
  def deemptify hash
    h = {}
    hash.each do |k,v|
      v = deemptify(v) if v.is_a?(Hash)
      v = v.map{|e| deemptify e}.compact if v.is_a?(Array)
      h[k] = v unless v.empty?
    end
    h unless h.empty?
  end
  
  @playlist = {:songs => []}
  def getFileFor song
    return unless filename = ask_open_file
    song[:file].text = filename
  end
  def songFields
    thisSong = {}
    hr
    stack {
      flow { thisSong[:preamble] = edit_line '(preamble)', :width => 150
             thisSong[:name] = edit_line 'Song Title', :width => -180, :right => 20, :top => 0 }
      here = flow { 
             thisSong[:button] = button("Choose song file...") { getFileFor thisSong }
             thisSong[:file] = para '' }
      thisSong[:postamble] = edit_box :width => -10
    }
    @playlist[:songs] << thisSong
  end
  def export
    return unless directory = ask_save_folder
    songsDirectory = File.join(directory, 'songs')
    File.makedirs(songsDirectory)
    # build data hash
    export = deemptify({
      'title'       => @playlist[:title].text,
      'description' => @playlist[:description].text,
      'author'      => @playlist[:author].text,
      'songs'       => @playlist[:songs].map {|song|
        { 'name'       => song[:name].text,
          'file'       => song[:file].text,
          'preamble'   => song[:preamble].text,
          'postamble'  => song[:postamble].text }
      }
    })
    # copy songs to destination directory
    export['songs'].each do |song|
      next unless song['file']
      filename = File.basename(song['file'])
      File.copy(song['file'], songsDirectory)
      song['file'] = "songs/#{filename}"
    end
    # export data to destination directory
    File.open(File.join(directory, 'playlist.yaml'), 'w') do |out|
      YAML.dump(export, out)
    end
    # copy playless app to destination directory
    File.copy('playless.rb', directory)
    
    alert("Your playlist app has been saved! Now you can package it as an application, and share it with all your friends.")
  end
  
  background silver..white
  stack(:margin => 20) {
    tagline "Why not make a playlist?"
    para "Everything is optional."
    stack {
      @playlist[:title] = edit_line 'Playlist Title', :width => -20
      @playlist[:description] = edit_box 'Playlist description', :width => -20, :height => 80, :margin => [0, 10, 0, 10]
      flow { para "by "; @playlist[:author] = edit_line 'me' }
    }
    @songStack = stack {}
    hr
    flow { button("Add a song") { @songStack.append{songFields} }
           button("Export") { export } }
  }
end