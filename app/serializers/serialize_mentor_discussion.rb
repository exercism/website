class SerializeMentorDiscussion
  include Mandate

  initialize_with :discussion, :context

  def call
    return if discussion.blank?

    {
      id: discussion.uuid,
      mentor: {
        avatar_url: discussion.mentor.avatar_url,
        handle: discussion.mentor.handle
      },
      student: {
        avatar_url: discussion.student.avatar_url,
        handle: discussion.student.handle
      },
      track: {
        title: discussion.track.title,
        icon_url: discussion.track.icon_url
      },
      exercise: {
        title: discussion.exercise.title,
        icon_url: discussion.exercise.icon_url
      },
      is_finished: context == :student ? discussion.finished_for_student? : discussion.finished_for_mentor?,
      is_unread: if context == :student
                   discussion.posts.where(seen_by_student: false).exists?
                 else
                   discussion.posts.where(seen_by_mentor: false).exists?
                 end,
      # TODO
      is_starred: true,
      posts_count: discussion.posts.count,
      iterations_count: discussion.iterations.count,
      created_at: discussion.created_at.iso8601,
      status: discussion.status,
      links: {
        self: if context == :student
                Exercism::Routes.track_exercise_mentor_discussion_path(discussion.track, discussion.exercise, discussion)
              else
                Exercism::Routes.mentoring_discussion_path(discussion)
              end,
        posts: if context == :student
                 Exercism::Routes.api_solution_discussion_posts_url(discussion.solution.uuid, discussion)
               else
                 Exercism::Routes.api_mentoring_discussion_posts_url(discussion)
               end,
        finish: Exercism::Routes.finish_api_mentoring_discussion_path(discussion),
        mark_as_nothing_to_do: Exercism::Routes.mark_as_nothing_to_do_api_mentoring_discussion_path(discussion)
      }
    }
  end
end
