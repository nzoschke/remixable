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

    library = ITunes::XMLLibrary.new('data/iTunes Music Library Noah Small.xml', 'noah')
    library.save
    assert_equal 800, MONGO['remixable']['songs'].count
  end
end