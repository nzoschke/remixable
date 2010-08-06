require 'lib/all'
require 'test/unit'

DB = MONGO['remixable_test']

class BaseTest < Test::Unit::TestCase
  def test_default
    assert true
  end

  def test_lifecycle
    DB['users'].remove
    DB['users'].insert({ :_id => 'noah', :password_hash => 'abc', :remote_url => 'http://hero2000.dyndns.org/' })

    DB['songs'].remove
    library = ITunes::XMLLibrary.new('data/iTunes Music Library Noah Small.xml', 'noah')
    library.save

    assert_equal 800, DB['songs'].count
    assert_equal 327, DB['songs'].distinct('artist').count
    assert_equal 10,  DB['songs'].distinct('album', :query => { :artist => 'Jay-Z' }).count
    assert_equal 13,  DB['songs'].find(:artist => 'Jay-Z', :album => 'The Blueprint').count

    # add one song to two libraries
    song = DB['songs'].find().sort([:_id, Mongo::DESCENDING]).limit(1).first
    DB['songs'].update( { :_id => song['_id'] } , { '$addToSet' => { 'libraries' => 'jason' } } )
    assert_equal 2, DB['songs'].find_one(:_id => song['_id'])['libraries'].count

    DB['logs'].remove
    noah = User.new('noah')
    noah.filter(nil)
    assert_equal 1, DB['logs'].find(:user_id => 'noah').count
    assert_equal({ "libraries" => nil, "playlists" => nil, "artists" => nil, "albums" => nil, "songs" => nil }, noah.filters)
    assert_equal 2,  noah.libraries.count
    
    noah.filter("libraries" => ['noah'])
    assert_equal({ "libraries" => ['noah'], "playlists" => nil, "artists" => nil, "albums" => nil, "songs" => nil }, noah.filters)
    assert_equal 1,  noah.libraries.count

    noah.filter(:artists => [noah.artists[132]]) # click Jay-Z
    assert_equal({ "libraries" => ['noah'], "playlists" => nil, "artists" => ['Jay-Z'], "albums" => nil, "songs" => nil }, noah.filters)
    assert_equal 10,  noah.albums.count
    assert_equal 125, noah.songs.count

    noah.filter(:artists => [noah.artists[132], noah.artists[164]]) # shift-click LCD Soundsystem
    assert_equal({ "libraries" => ['noah'], "playlists" => nil, "artists" => ['Jay-Z', 'LCD Soundsystem'], "albums" => nil, "songs" => nil }, noah.filters)
    assert_equal 12, noah.albums.count # tricky; one album overlap!
    assert_equal 138, noah.songs.count

    assert_equal 4, DB['logs'].count
  end
end