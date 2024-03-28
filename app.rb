require 'sinatra'
require 'tilt/erubis'
require 'redcarpet'

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
  def render_md(md_text)
    Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(md_text)
  end

  def add_message(msg)
    session[:messages] << msg
  end

  def signed_in?
    session[:user_id] && !session[:user_id].empty? && session[:username] &&
      !session[:username].empty?
  end

  def sign_in(username)
    session[:username] = username
    session[:user_id] = @db.get_user_id(username)
  end

  def sign_out
    session[:username] = nil
    session[:user_id] = nil
  end

  def valid_post(title, user_id, content)
    title.size > 0 && content.size > 0 && user_id =~ /[0-9]/
  end
end

# TODO: implement page system
# TODO: Implement author name separately from username
# TODO: make sure our markdown render implementation is safe from XSS attacks.

get '/' do
  redirect "/page/0"
end

get "/page/:page" do |page|
  @page_title = 'Simple Blog'
  @page = page.to_i
  @posts_per_page = 3
  result = @db.fetch_n_posts(@posts_per_page, @page)
  @posts = Post.list_from_PG(result)
  @last_page_bool = result.ntuples <= @posts_per_page

  erb :feed, layout: :layout
end

get '/users/signup' do
  erb :signup
end

post '/users/signup' do
  username, password = params[:username], params[:password]
  if @db.existing_user?(username)
    add_message(
      'This user already exists. Please try a different username or sign in.',
    )
    status 422
    erb :signup
  else
    @db.add_user(username, password)
    sign_in(username)
    'Thank you for signing up!'
    redirect '/'
  end
end

get '/users/signin' do
  erb :signin
end

post '/users/signin' do
  username, password = params[:username], params[:password]
  if @db.valid_user?(username, password)
    sign_in(username)
    add_message('Welcome!')
    redirect '/'
  else
    add_message('Invalid credentials.')
    status 422
    erb :signin
  end
end

post '/users/signout' do
  sign_out
  add_message('You have been signed out!')
  redirect '/'
end

get '/posts/new' do
  erb :newpost
end

post '/posts/new' do
  title, content = params[:title], params[:content]
  user_id = session[:user_id]

  if valid_post(title, user_id, content)
    @db.add_post(title, user_id, content)
    add_message('The post has been submitted.')
    redirect '/'
  else
    add_message('Invalid post')
    status 422
    erb :newpost
  end
end

get '/posts/:post_id' do |post_id|
  result = @db.fetch_post(post_id)
  @post = Post.from_PG(result)
  erb :post
end


get '/posts/:post_id/edit' do |post_id|
  result = @db.fetch_post(post_id)
  @post = Post.from_PG(result)
  erb :edit
end

post '/posts/:post_id' do |post_id|
  new_title, new_content = params[:new_title], params[:new_content]
  user_id = session[:user_id]
  # Need to verify that current user is original author of post
  # current solution is not secure/robust
  # if @db.has_edit_permissions?(user_id, post_id)

  @db.update_post(post_id, new_title, new_content) 
  result = @db.fetch_post(post_id) # This db query can be optimised/eliminated
  @post = Post.from_PG(result)
  erb :post
end