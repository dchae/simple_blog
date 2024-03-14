require 'sinatra'
require 'tilt/erubis'

require_relative 'blogtools'
require_relative 'db_handler'

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
  set :erb, escape_html: true
end

configure(:development) do
  require 'sinatra/reloader'
  also_reload 'db_handler.rb'
  also_reload 'blogtools.rb'
end

before do
  session[:messages] ||= []
  @db = DatabaseHandler.new(logger)
end

helpers do
  # def render_md(md_text)
  #   Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(md_text)
  # end
  def signed_in?
    session[:username] && !session[:username].empty?
  end
end

# TODO: implement page system
# TODO: Implement author name separately from username

get '/' do
  @page_title = 'Simple Blog'
  result = @db.fetch_posts
  @posts = Post.list_from_PG(result)

  erb :home, layout: :layout
end

get '/users/signup' do
  erb :signup
end

post '/users/signup' do
  username, password = params[:username], params[:password]
  if @db.existing_user?(username)
    session[:messages] <<
      'This user already exists. Please try a different username or sign in.'
    status 422
    erb :signup
  else
    @db.add_user(username, password)
    session[:username] = username
    session[:messages] << 'Thank you for signing up!'
    redirect '/'
  end
end
