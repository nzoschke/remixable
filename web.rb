require 'lib/all'
require 'sinatra'

get '/' do
  @user = User.new('noah')
  @user.filtered.clear({:user_id => 'noah', :from => 'web'})
  erb :index
end

get '/state' do
  @user = User.new('noah')
  @user.data
end

put '/state' do
  @user = User.new('noah')
	puts params.inspect
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
