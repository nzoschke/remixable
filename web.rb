require 'lib/all'
require 'sinatra'

get '/' do
  @user = User.new('noah')
  @user.filtered.clear({:user_id => 'noah', :from => 'web'})
  #@user.filtered.update("libraries" => ['noah'])
  erb :index
end

get '/folder' do
  songs = DB['songs'].find({:path => /^Music\//}).sort([:path, 'ascending'])

  @root = {"path" => "Music", "children" => []}
  @artist = @album = {}
  songs.each do |song|
    root_path, artist_path, album_path, file_path = song["path"].split('/')

    if @artist["path"] != artist_path
      @artist = {"path" => artist_path, "children" => []}
      @root["children"] << @artist
    end
    
    if @album["path"] != album_path
      @album = {"path" => album_path, "songs" => []}
      @artist["children"] << @album
    end

    @album["songs"] << song
  end

  [@root].to_json
end

get '/state' do
  @user = User.new('noah')
  @user.data
end

put '/state' do
  # HACK; uki.post is not sending empty arrays, client modified to send magic string instead
  params.each {|k,v| params[k] = nil if v === "nil"}
  puts params.inspect
  @user = User.new('noah')
  @user.filtered.update(params)
  @user.data
end

get %r{\.cjs$} do
  path = request.path.sub(/\.cjs$/, '.js').sub(%r{^/}, './')
  pass unless File.exists? path

  response.header['Content-type'] = 'application/x-javascript; charset=UTF-8'
  begin
    Uki::Builder.new(path, :optimize => false).code
  rescue Exception => e
    message = e.message.sub(/\n/, '\\n')
    "alert('#{message}')"
  end
end
