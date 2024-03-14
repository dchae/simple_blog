class Post
  def initialize(title, user_id, author, timestamp, content)
    @title = title
    @user_id = user_id
    @author = author
    @timestamp = timestamp
    @content = content
  end

  attr_reader :title, :user_id, :author, :timestamp, :content

  def self.list_from_PG(result)
    result.map do |tuple|
      title = tuple['title']
      user_id = tuple['user_id']
      author = tuple['username']
      timestamp = tuple['post_date']
      content = tuple['content']
      Post.new(title, user_id, author, timestamp, content)
    end
  end
end
