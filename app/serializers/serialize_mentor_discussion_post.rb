class SerializeMentorDiscussionPost
  include Mandate

  initialize_with :post, :user

  def call
    return if post.blank?

    {
      uuid: post.uuid,
      iteration_idx: post.iteration_idx,
      author_handle: post.author.handle,
      author_flair: post.author.flair,
      author_avatar_url: post.author.avatar_url,
      by_student: post.by_student?,
      content_markdown: post.content_markdown,
      content_html: post.content_html,
      updated_at: post.updated_at.iso8601,
      links:
    }
  end

  private
  def links
    return {} unless post.author == user

    post.try(:links) || default_links
  end

  def default_links
    if post.by_student?
      link = Exercism::Routes.api_solution_discussion_post_url(post.discussion.solution.uuid, post.discussion, post)
    else
      link = Exercism::Routes.api_mentoring_discussion_post_url(post.discussion, post)
    end

    {
      edit: link,
      delete: link
    }
  end
end
