require 'pg'
require 'bcrypt'

class DatabaseHandler
  def initialize(logger)
    @db =
      if Sinatra::Base.production?
        PG.connect(ENG['DATABASE_URL'])
      else
        PG.connect(dbname: 'simple_blog')
      end
    @logger = logger
  end

  def query(sql, *params)
    @logger.info("#{sql}: #{params}")
    @db.exec_params(sql, params)
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
end
