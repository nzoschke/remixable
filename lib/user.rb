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
    {:filters => filtered.filters, :libraries => filtered.libraries, :artists => filtered.artists, :albums => filtered.albums, :songs => filtered.songs}.to_json
  end
end

class Filterer
  attr_accessor :user_id
  EMPTY_FILTERS = { 'libraries' => nil, 'playlists' => nil, 'artists' => nil, 'albums' => nil, 'songs' => nil }

  def initialize(user_id)
    self.user_id = user_id
  end

  def update(obj, context=nil)
    return clear(context) if not obj
    new_filters = filters
    new_filters = new_filters.update(obj)
    DB['logs'].insert({ :user_id => user_id, :filters => new_filters, :context => context })
  end

  def clear(context=nil)
    DB['logs'].insert({ :user_id => user_id, :filters => EMPTY_FILTERS, :context => context })
  end

  def filters
    latest_log = DB['logs'].find( :user_id => user_id ).sort([:_id, Mongo::DESCENDING]).limit(1).first
    latest_log ? latest_log['filters'] : EMPTY_FILTERS
  end

  def query(filter_fields)
    query = {}
    filter_fields.each { |field|
      db_field = field == 'libraries' ? field : field[0..-2] # GROSS
      query[db_field.to_sym] = {"$in" => filters[field]} if filters[field]
    }
    query
  end

  def libraries
    DB['songs'].distinct('libraries').flatten.uniq # TODO: inefficient?
  end

  def artists
    DB['songs'].distinct('artist', :query => query(['libraries']))
  end

  def albums
    DB['songs'].distinct('album', :query => query(['libraries', 'artists']))
  end

  def songs_cursor
    DB['songs'].find(query(['libraries', 'artists', 'albums']))
  end

  def songs
    songs_cursor.collect { |d| d }
  end
end