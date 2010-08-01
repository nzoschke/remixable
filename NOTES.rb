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

class User
  has_many :playlists
  has_many :library_songs
  has_many :playlist_songs
end

class Song
  unique album, artist, title, length tuple
  has_many :files
end