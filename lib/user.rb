class User
  attr_accessor :user_id, :filtered

  def initialize(user_id)
    self.user_id = user_id
    self.filtered = Filterer.new(user_id)
  end

  def self.[](user_id)
    User.new(user_id)
  end

  def data(opts={})
    {:libraries => filtered.libraries, :artists => filtered.artists, :albums => filtered.albums, :songs => filtered.songs}.to_json
  end
end

class Filterer
  attr_accessor :user_id

  def initialize(user_id)
    self.user_id = user_id
  end

  def update(obj, options={})
    new_filters = filters
    new_filters = new_filters.update(obj) if obj
    DB['logs'].insert({ :user_id => user_id, :filters => new_filters })    
  end

  def filters
    empty_filters = { 'libraries' => nil, 'playlists' => nil, 'artists' => nil, 'albums' => nil, 'songs' => nil }
    latest_log = DB['logs'].find( :user_id => user_id ).sort([:_id, Mongo::DESCENDING]).limit(1).first
    latest_log ? latest_log['filters'] : empty_filters
  end

  def libraries
    all_libraries = DB['songs'].distinct('libraries').flatten.uniq # inefficient
    return all_libraries if !filters['libraries']
    return all_libraries & filters['libraries']
  end

  def artists
    return DB['songs'].distinct('artist') if !filters['libraries']
    return DB['songs'].distinct('artist', :query => {:libraries => {"$in" => filters['libraries']}})
  end

  def albums
    return DB['songs'].distinct('album') if !filters['libraries']
    return DB['songs'].distinct('album', :query => {:libraries => {"$in" => filters['libraries']}}) if !filters['artists']
    return DB['songs'].distinct('album', :query => {:libraries => {"$in" => filters['libraries']}, :artist => {"$in" => filters['artists']}})
  end

  def songs_cursor
    return DB['songs'].find() if !filters['libraries']
    return DB['songs'].find(:libraries => {"$in" => filters['libraries']}) if !filters['artists']
    return DB['songs'].find(:libraries => {"$in" => filters['libraries']}, :artist => {"$in" => filters['artists']}) if !filters['albums']
    return DB['songs'].find(:libraries => {"$in" => filters['libraries']}, :artist => {"$in" => filters['artists']}, :album => {"$in" => filters['albums']})
  end

  def songs
    songs_cursor.collect { |d| d }
  end
end