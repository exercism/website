class Mentor::RequestComment
  include ActiveModel::Model

  attr_accessor(
    :uuid,
    :author,
    :by_student,
    :content_markdown,
    :content_html,
    :iteration_idx,
    :updated_at,
    :request
  )

  def self.from(request)
    return nil unless request

    if request.discussion
      return nil if request.comment_html.blank?

      iteration_idx = request.discussion.posts.first.iteration_idx if request.discussion.posts.any?
    end

    iteration_idx ||= request.iterations.last.idx

    new(
      uuid: "request-comment",
      iteration_idx:,
      author: request.student,
      by_student: true,
      content_markdown: request.comment_markdown,
      content_html: request.comment_html,
      updated_at: request.created_at,
      request:
    )
  end

  def by_student? = by_student

  def links
    {
      edit: Exercism::Routes.api_solution_mentor_request_url(request.solution.uuid, request)
    }
  end
end
