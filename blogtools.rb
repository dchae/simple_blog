class Post
  def initialize(title, user_id, username, timestamp, content)
    @title = title
    @user_id = user_id
    @username = username
    @timestamp = timestamp
    @content = content
  end

  attr_reader :title, :user_id, :username, :timestamp, :content

  def self.list_from_PG(result)
    result.map do |tuple|
      title = tuple['title']
      user_id = tuple['user_id']
      username = tuple['username']
      timestamp = tuple['post_date']
      content = tuple['content']
      Post.new(title, user_id, username, timestamp, content)
    end
  end
end
