class SerializeMentorDiscussions
  include Mandate

  initialize_with :discussions

  def call
    discussions.includes(:user, :exercise, :track).
      map { |r| serialize_discussion(r) }
  end

  private
  def serialize_discussion(discussion)
    {
      # TODO: Maybe expose a UUID instead?
      id: discussion.uuid,

      track_title: discussion.track_title,
      track_icon_url: discussion.track_icon_url,
      exercise_title: discussion.exercise_title,

      mentee_handle: discussion.student_handle,
      mentee_avatar_url: discussion.student_avatar_url,

      # TODO: Should this be discussioned_at?
      updated_at: discussion.created_at.to_i,

      # TODO: Add all these
      is_starred: true,
      posts_count: 4,

      # TODO: Rename this to web_url
      url: Exercism::Routes.mentor_discussion_url(discussion)
    }
  end
end
