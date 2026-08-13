class SerializeSolutionComment
  include Mandate

  initialize_with :comment, :for_user

  def call
    {
      uuid: comment.uuid,
      # Reputation, flair and avatar are deliberately absent. They change
      # whenever the commenter does anything anywhere, so embedding them here
      # would invalidate every page that person has ever commented on. The
      # client fetches them from /api/v2/users/:handle.json instead.
      author: {
        handle: comment.author.handle
      },
      content_markdown: comment.content_markdown,
      content_html: comment.content_html,
      updated_at: comment.updated_at.iso8601,
      links:
    }
  end

  def links
    return {} if for_user.blank?
    return {} unless for_user.id == comment.user_id

    solution = comment.solution
    {
      edit: Exercism::Routes.api_track_exercise_community_solution_comment_url(solution.track, solution.exercise, solution.user,
        comment),
      delete: Exercism::Routes.api_track_exercise_community_solution_comment_url(solution.track, solution.exercise, solution.user,
        comment)
    }
  end
end
