class SerializeMentorDiscussion
  include Mandate

  initialize_with :discussion, :student_favorited, :is_finished, :is_unread, :links

  def call
    {
      uuid: discussion.uuid,
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
        flair: discussion.student_flair,
        avatar_url: discussion.student_avatar_url,
        is_favorited: student_favorited
      },
      mentor: {
        handle: discussion.mentor.handle,
        flair: discussion.mentor.flair,
        avatar_url: discussion.mentor.avatar_url
      },

      created_at: discussion.created_at.iso8601,
      updated_at: discussion.updated_at.iso8601,

      is_finished:,
      is_unread:,
      posts_count: discussion.num_posts,
      iterations_count: discussion.solution.num_iterations,
      links:
    }
  end
end
