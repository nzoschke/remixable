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
    noah = User['noah']
    noah.filtered.update(nil)
    assert_equal 1, DB['logs'].find(:user_id => 'noah').count

    assert_equal({ "libraries" => nil, "playlists" => nil, "artists" => nil, "albums" => nil, "songs" => nil }, noah.filtered.filters)
    assert_equal 2,  noah.filtered.libraries.count
    assert noah.data

    noah.filtered.update("libraries" => ['noah'])
    assert_equal({ "libraries" => ['noah'], "playlists" => nil, "artists" => nil, "albums" => nil, "songs" => nil }, noah.filtered.filters)
    assert_equal 1,  noah.filtered.libraries.count
    assert_equal 800, noah.filtered.songs.count
    assert noah.data

    noah.filtered.update(:artists => [noah.filtered.artists[132]]) # click Jay-Z
    assert_equal({ "libraries" => ['noah'], "playlists" => nil, "artists" => ['Jay-Z'], "albums" => nil, "songs" => nil }, noah.filtered.filters)
    assert_equal 10,  noah.filtered.albums.count
    assert_equal 125, noah.filtered.songs.count
    assert noah.data

    noah.filtered.update(:artists => [noah.filtered.artists[132], noah.filtered.artists[164]]) # shift-click LCD Soundsystem
    assert_equal({ "libraries" => ['noah'], "playlists" => nil, "artists" => ['Jay-Z', 'LCD Soundsystem'], "albums" => nil, "songs" => nil }, noah.filtered.filters)
    assert_equal 12, noah.filtered.albums.count # tricky; one album overlap!
    assert_equal 138, noah.filtered.songs.count
    assert noah.data

    noah.filtered.clear({:user_id => 'tester', :from => 'test'})
    assert_equal 800, noah.filtered.songs.count

    # log can carry other context
    noah.filtered.update("libraries" => ['noah'], "_method" => 'put')
    assert_equal 'put', noah.filtered.filters['_method']

    assert_equal 6, DB['logs'].count
  end
end