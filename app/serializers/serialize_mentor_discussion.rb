class SerializeMentorDiscussion
  include Mandate

  initialize_with :discussion, :user

  def call
    {
      id: discussion.uuid,
      status: discussion.status,
      finished_at: discussion.finished_at,
      finished_by: discussion.finished_by,

      track: {
        title: discussion.track_title,
        icon_url: discussion.track_icon_url
      },
      exercise: {
        title: discussion.exercise_title,
        icon_url: discussion.exercise.icon_url
      },
      student: {
        handle: discussion.student_handle,
        avatar_url: discussion.student_avatar_url,
        isStarred: true # Only show this if the user is the mentor
      },
      mentor: {
        handle: discussion.mentor.handle,
        avatar_url: discussion.mentor.avatar_url
      },

      created_at: discussion.created_at.iso8601,
      updated_at: discussion.updated_at.iso8601,

      is_finished: finished?,
      is_unread: true,
      posts_count: 4,
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
        self: Exercism::Routes.mentoring_discussion_url(discussion),
        posts: Exercism::Routes.api_mentoring_discussion_posts_url(discussion),
        finish: Exercism::Routes.finish_api_mentoring_discussion_url(discussion),
        mark_as_nothing_to_do: Exercism::Routes.mark_as_nothing_to_do_api_mentoring_discussion_url(discussion)
      }
    else
      {
        self: Exercism::Routes.track_exercise_mentor_discussion_url(discussion.track, discussion.exercise, discussion),
        posts: Exercism::Routes.api_solution_discussion_posts_url(discussion.solution.uuid, discussion),
        finish: Exercism::Routes.finish_api_solution_discussion_url(discussion.solution.uuid, discussion.uuid)
      }
    end
  end
end
