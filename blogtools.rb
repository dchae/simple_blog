class Post
  def initialize(id, title, user_id, username, timestamp, content)
    @id = id
    @title = title
    @user_id = user_id
    @username = username
    @timestamp = timestamp
    @content = content
  end

  attr_reader :id, :title, :user_id, :username, :timestamp, :content

  def self.list_from_PG(result)
    result.map do |tuple|
      id = tuple['id']
      title = tuple['title']
      user_id = tuple['user_id']
      username = tuple['username']
      timestamp = tuple['post_date']
      content = tuple['content']
      Post.new(id, title, user_id, username, timestamp, content)
    end
  end

  def self.from_PG(result)
    list_from_PG(result).first
  end
end
