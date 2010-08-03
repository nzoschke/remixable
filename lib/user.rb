class User
  attr_accessor :user_id

  def initialize(user_id)
    self.user_id = user_id
  end

  def select(obj, options={})
    new_selections = selections
    new_selections = new_selections.update(obj) if obj
    DB['logs'].insert({ :user_id => user_id, :selections => new_selections })    
  end

  def selections
    empty_selections = { :libraries => nil, :playlists => nil, :artists => nil, :albums => nil, :songs => nil }
    latest_log = DB['logs'].find( :user_id => user_id ).sort([:_id, Mongo::DESCENDING]).limit(1).first
    latest_log ? latest_log['selections'] : empty_selections
  end

  def artists
    return DB['songs'].distinct('artist') if !selections['libraries']
    return DB['songs'].distinct('artist', :query => { :libraries => {"$in" => selections['libraries']}})
  end

  def albums
    return DB['songs'].distinct('album') if !selections['libraries']
    return DB['songs'].distinct('album', :query => { :libraries => {"$in" => selections['libraries']} }) if !selections['artists']
    return DB['songs'].distinct('album', :query => { :libraries => {"$in" => selections['libraries']}, :artist => {"$in" => selections['artists']} })
  end

  def songs
    return DB['songs'] if !selections['libraries']
    return DB['songs'].find(:libraries => {"$in" => selections['libraries']}) if !selections['artists']
    return DB['songs'].find(:libraries => {"$in" => selections['libraries']}, :artist => {"$in" => selections['artists']}) if !selections['albums']
    return DB['songs'].find(:libraries => {"$in" => selections['libraries']}, :artist => {"$in" => selections['artists']}, :album => {"$in" => selections['albums']})
  end
end