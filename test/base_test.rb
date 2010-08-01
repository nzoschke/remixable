require 'lib/all'
require 'test/unit'
#require 'contest'

class BaseTest < Test::Unit::TestCase
  def test_default
    assert true
  end

  def test_lifecycle
    MONGO['remixable']['users'].remove
    MONGO['remixable']['users'].insert({ :_id => 'noah', :username => 'noah', :password_hash => 'abc', :remote_url => 'http://hero2000.dyndns.org/' })

    MONGO['remixable']['songs'].remove
    library = ITunes::XMLLibrary.new('data/iTunes Music Library Noah Small.xml', 'noah')
    library.save
    assert_equal 800, MONGO['remixable']['songs'].count
    
    assert_equal 327, MONGO['remixable']['songs'].distinct('artist').count
    assert_equal 10,  MONGO['remixable']['songs'].distinct('album', :query => { :artist => 'Jay-Z' }).count
    assert_equal 13,  MONGO['remixable']['songs'].find(:artist => 'Jay-Z', :album => "The Blueprint").count
  end
end