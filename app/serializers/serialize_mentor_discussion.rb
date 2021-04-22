class SerializeMentorDiscussion
  include Mandate

  initialize_with :discussion

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

      # TODO: Add all these
      is_finished: true,
      is_starred: true,
      is_unread: true,
      posts_count: 4,

      # TODO: Rename this to web_url
      links: {
        self: Exercism::Routes.mentoring_discussion_url(discussion)
      }
    }
  end
end
