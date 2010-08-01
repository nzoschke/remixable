begin
  require ::File.expand_path('../env.rb', __FILE__) # 'source' dev environment if present
rescue LoadError => e
end

require 'bson'
require 'mongo'

require 'lib/itunes'

MONGO = Mongo::Connection.from_uri(ENV['MONGO_URL'] || 'mongodb://127.0.0.1:27017/')

class Numeric
  def roundup(nearest=10)
    self % nearest == 0 ? self : self + nearest - (self % nearest)
  end
  def rounddown(nearest=10)
    self % nearest == 0 ? self : self - (self % nearest)
  end
end