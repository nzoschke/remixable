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

    DB['logs'].remove
    noah = User.new('noah')
    noah.select(nil)
    assert_equal 1, DB['logs'].find(:user_id => 'noah').count
    assert_equal({ "libraries" => nil, "playlists" => nil, "artists" => nil, "albums" => nil, "songs" => nil }, noah.selections)
    
    noah.select("libraries" => ['noah'])
    assert_equal({ "libraries" => ['noah'], "playlists" => nil, "artists" => nil, "albums" => nil, "songs" => nil }, noah.selections)

    noah.select(:artists => [noah.artists[132]]) # click Jay-Z
    assert_equal({ "libraries" => ['noah'], "playlists" => nil, "artists" => ['Jay-Z'], "albums" => nil, "songs" => nil }, noah.selections)
    assert_equal 10,  noah.albums.count
    assert_equal 125, noah.songs.count

    noah.select(:artists => [noah.artists[132], noah.artists[164]]) # shift-click LCD Soundsystem
    assert_equal({ "libraries" => ['noah'], "playlists" => nil, "artists" => ['Jay-Z', 'LCD Soundsystem'], "albums" => nil, "songs" => nil }, noah.selections)
    assert_equal 12, noah.albums.count # tricky; one album overlap!
    assert_equal 138, noah.songs.count

    assert_equal 4, DB['logs'].count
  end
end