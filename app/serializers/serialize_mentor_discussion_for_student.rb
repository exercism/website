class SerializeMentorDiscussionForStudent
  include Mandate

  initialize_with :discussion

  def call
    SerializeMentorDiscussion.(
      discussion,
      nil,
      discussion.finished_for_student?,
      discussion.posts.where(seen_by_student: false).exists?,
      {
        self: Exercism::Routes.track_exercise_mentor_discussion_url(discussion.track, discussion.exercise, discussion),
        posts: Exercism::Routes.api_solution_discussion_posts_url(discussion.solution.uuid, discussion),
        finish: Exercism::Routes.finish_api_solution_discussion_url(discussion.solution.uuid, discussion.uuid)
      }
    )
  end
end
