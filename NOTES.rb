TODO
====

Register User
Upload iTunes XML
Library Treelist
  Artist, Album, Title hierarchy
Playlist Treelist
Library Search

GETTING STARTED
===============
mongod --dbpath data/db/

DATA MODEL
==========
db.songs.ensureIndex({ artist: 1, album: 1 });

db.songs.find({}).sort({ artist: 1, album: 1, num: 1 });                          # all songs
db.songs.distinct('artist');                                                      # all artists
db.songs.distinct('album');                                                       # all albums
db.songs.distinct('album' , { artist: 'Daft Punk' } );                            # all albums for an artist
db.songs.find({ artist: 'Daft Punk' }).sort({ album: 1, num: 1 });                # all songs for an artist
db.songs.find({ artist: 'Daft Punk', album: 'Homework' }).sort({ num: 1 });       # all songs for an artist


db.songs.find({artist: 'Daft Punk'}).sort({album: 1, track_num: 1});
db.items.update( { sku : 123 } , { "$set" : { "features.zoom" : "5" } } )


Precalculate / insert every:

  song
  artist    => albums
  artist    => songs
  album     => songs
  playlist  => songs

for the set of songs.

Update every:
  song
  
  all the references to a song
    calculate out references from record
      song => playlists
      song => album
      song => artist

  recalculate
    artist => album (via artist => song => album)

keys
  artist
  artist:album

  album['artist']

  artist.albums
  

  Artists['Daft Punk'].albums
  Artists['Daft Punk'].songs
  Albums['Homework'].songs
  Playlist['Noah/mixable010'].songs

  Playlist['Noah/Now Playing']
  Playlist['Noah/Display']

  State['Noah'].log # total state plus log record of transition ; pop last

for a song update.


class User < ActiveRecord::Base
   belongs_to              :portfolio
   has_one                 :project_manager
   has_many                :milestones
   has_and_belongs_to_many :categories
end

class Song < ActiveRecord::Base
  attr_accessor :uuid, :name
  attr_accessor :artist_name, :album_name
  
  has_one :album
  has_one :artist
end

class Album < ActiveRecord::Base
  belongs_to  :song
  has_many    :songs

  def key "#{artist}:#{album}" ; end
end

class Artist < ActiveRecord::Base
  belongs_to :album
  belongs_to :song

  def key "#{artist}" ; end
end

class Playlist < ActiveRecord::Base
  # document to song uuids?
end


STATE MACHINE
=============
Song
  Artist Song
    Artist Album Song
      Playlist Song
        Playing Song
        Stopped Song
        Paused Song
        Selected Song

DATA STRUCTURES
===============

<ol class="tree">
  <li>
    <label for="artist1">!!!</label> <input type="checkbox" checked id="artist1" />
    <ol>
      <li>
        <label for="album1">Louden Up Now</label> <input type="checkbox" id="album1" />
        <ol>
          <li class="file"><a href="01.mp3">Song 01</a></li>
        </ol>
      </li>
    </ol>
  </li>
</ol>