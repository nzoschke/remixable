require 'plist'

module ITunes
  class XMLLibrary
    attr_accessor :plist

    def initialize(path, user_id)
      path = File.expand_path path
      raise RuntimeError.new("iTunes Library XML file not found") unless File.exists? path
      self.plist = Plist::parse_xml(path)
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
        track = Track.new(data)
        MONGO['remixable']['songs'].insert(track.to_bson)
      }
    end

  end

  class Track
    attr_accessor :artist, :album, :title, :number
    
    def initialize(plist_data)
      self.artist = plist_data['Artist'] || 'Unknown Artist'
      self.album  = plist_data['Album']  || 'Unknown Album'
      self.title  = plist_data['Name']
      self.number = plist_data['Track Number']
    end

    def _id
      "#{artist}:#{album}:#{title}".downcase
    end

    def to_bson
      { :_id => _id, :artist => artist, :album => album, :title => title, :number => number }
    end
  end
end