class SerializeMentorDiscussionPosts
  include Mandate

  initialize_with :posts

  def call
    posts.map do |post|
      {
        id: post.uuid,
        author_handle: post.author.handle,
        author_avatar_url: post.author.avatar_url,
        by_student: post.by_student?,
        content_html: post.content_html,
        updated_at: post.updated_at.iso8601
      }
    end
  end
end
