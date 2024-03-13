class Post
  def initialize(title, user_id, timestamp, content)
    @title = title
    @user_id = user_id
    @timestamp = timestamp
    @content = content
  end

  attr_reader :title, :user_id, :timestamp, :content

  def self.new_from_PG(result)
    Post.new(title, user_id, timestamp, content)
  end
end