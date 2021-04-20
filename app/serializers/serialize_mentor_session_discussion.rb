class SerializeMentorSessionDiscussion
  include Mandate

  initialize_with :discussion, :user

  def call
    return if discussion.blank?

    {
      id: discussion.uuid,
      is_finished: finished?,
      links: links
    }
  end

  private
  delegate :mentor, to: :discussion

  def finished?
    if user == mentor
      discussion.finished_for_mentor?
    else
      discussion.finished_for_student?
    end
  end

  def links
    if user == mentor
      {
        posts: Exercism::Routes.api_mentoring_discussion_posts_url(discussion)
      }.tap do |links|
        links[:finish] = Exercism::Routes.finish_api_mentoring_discussion_path(discussion) unless finished?

        links[:mark_as_nothing_to_do] = Exercism::Routes.mark_as_nothing_to_do_api_mentoring_discussion_path(discussion)
      end
    else
      {
        posts: Exercism::Routes.api_solution_discussion_posts_url(discussion.solution.uuid, discussion)
      }
    end
  end
end
