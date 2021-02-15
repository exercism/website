class SerializeMentorDiscussionPost
  include Mandate

  initialize_with :post, :user

  def call
    {
      id: post.uuid,
      iteration_idx: post.iteration_idx,
      author_id: post.author.id,
      author_handle: post.author.handle,
      author_avatar_url: post.author.avatar_url,
      by_student: post.by_student?,
      content_markdown: post.content_markdown,
      content_html: post.content_html,
      updated_at: post.updated_at.iso8601,
      links: post.try(:links) || links
    }
  end

  private
  def links
    return {} if post.uuid.blank?
    return {} unless post.author == user

    if post.by_student?
      {
        update: Exercism::Routes.api_solution_discussion_post_url(post.discussion.solution.uuid, post.discussion, post)
      }
    else
      {
        update: Exercism::Routes.api_mentoring_discussion_post_url(post.discussion, post)
      }
    end
  end
end
