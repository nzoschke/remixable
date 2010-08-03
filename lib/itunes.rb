require 'plist'

module ITunes
  class XMLLibrary
    attr_accessor :plist, :user_id

    def initialize(path, user_id)
      path = File.expand_path path
      raise RuntimeError.new("iTunes Library XML file not found") unless File.exists? path
      self.plist = Plist::parse_xml(path)
      self.user_id = user_id
    end

    def songs
      @songs ||= DB['songs']
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
        _id = DB['songs'].insert(track.to_bson)
        DB['songs'].update( { :_id => _id } , { '$addToSet' => { 'libraries' => user_id } } )
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

    def to_bson
      { :artist => artist, :album => album, :title => title, :number => number }
    end
  end

end