require 'plist'

module ITunes
  class XMLLibrary
    attr_reader :plist, :root, :user_id

    def initialize(path, user_id)
      path = File.expand_path path
      raise RuntimeError.new("iTunes Library XML file not found") unless File.exists? path
      @plist = Plist::parse_xml(path)
      @root = self.plist['Music Folder']
      @user_id = user_id
    end

    def playlists
      playlists = {}
      plist['Playlists'].each { |p| playlists[p['Name']] = p }
      return playlists
    end

    def display
      plist['Playlists'].each { |playlist|
        puts "#{playlist['Name']} (#{playlist['Playlist Items'].length rescue 0} songs)\n"
      }
    end

    def save
      plist['Tracks'].each { |id,data|
        track = Track.new(data, self)
        if !track.path
          puts "Skipping #{track.location}"
          next
        end

        DB['songs'].save(track.to_bson)
      }
    end
  end

  class Track
    attr_accessor :_id, :artist, :album, :title, :number, :location, :path
    
    def initialize(data, library)
      @_id      = data['Persistent ID']
      @artist   = data['Artist'] || 'Unknown Artist'
      @album    = data['Album']  || 'Unknown Album'
      @title    = data['Name']
      @number   = data['Track Number']
      @location = data['Location']
      @path     = @location.gsub(/^#{library.root}/, '')
      @path     = nil if @path == @location
    end

    def to_bson
      { :_id => _id, :artist => artist, :album => album, :title => title, :number => number, :path => path }
    end
  end

end