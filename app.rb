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
end

get '/' do
  @page_title = 'Simple Blog'
  @posts = [Post.new("Test Post", "1", "2024-03-13 00:03:57", "Some sample content in plain text.")]
  # Need to figure out how to get author name into the post class
  erb :home, layout: :layout
end