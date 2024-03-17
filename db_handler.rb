require 'pg'
require 'bcrypt'

require_relative 'blogtools'

class DatabaseHandler
  def initialize(logger)
    @db =
      if Sinatra::Base.production?
        PG.connect(ENG['DATABASE_URL'])
      else
        PG.connect(dbname: 'simple_blog')
      end
    @logger = logger
    # setup_schema # Implement auto setup of sql tables and database when it doesn't already exist
  end

  def query(sql, *params)
    @logger.info("#{sql}: #{params}")
    @db.exec_params(sql, params)
  end

  def fetch_posts()
    sql = <<~SQL
    SELECT posts.id, title, user_id, username, post_date, content FROM posts 
    INNER JOIN users ON posts.user_id = users.id
    ORDER BY post_date DESC;
    SQL
    result = query(sql)
  end

  def fetch_post(post_id)
    sql = <<~SQL
      SELECT posts.*, username
      FROM posts 
      INNER JOIN users ON posts.user_id = users.id
      WHERE posts.id = $1;
    SQL
    result = query(sql, post_id)
  end

  def add_post(title, user_id, content)
    sql = 'INSERT INTO posts (title, user_id, content) VALUES ($1, $2, $3)'
    query(sql, title, user_id, content)
  end

  def update_post(post_id, new_title, new_content)
    sql = <<~SQL
      UPDATE posts 
      SET title = $1,
          content = $2,
          last_updated_date = NOW()
      WHERE id = $3;
      SQL
    query(sql, new_title, new_content, post_id)
  end

  def add_user(username, secret)
    unless existing_user?(username)
      pw_hash = BCrypt::Password.create(secret).to_s
      sql = 'INSERT INTO users (username, pw_hash) VALUES ($1, $2)'
      query(sql, username, pw_hash)
    end
  end

  def existing_user?(username)
    sql = 'SELECT * FROM users WHERE username = $1'
    result = query(sql, username)
    result.ntuples == 1
  end

  def valid_user?(username, password)
    sql = 'SELECT pw_hash FROM users WHERE username = $1'
    result = query(sql, username)
    return false unless result.ntuples == 1
    pw_hash = result.first['pw_hash']
    BCrypt::Password.new(pw_hash) == password
  end

  def get_user_id(username)
    sql = 'SELECT id FROM users WHERE username = $1'
    result = query(sql, username)
    result.first["id"]
  end
end
