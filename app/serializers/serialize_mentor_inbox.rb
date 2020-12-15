class SerializeMentorInbox
  include Mandate

  initialize_with :inbox

  def call
    {
      results: discussions,
      meta: { current: page, total: inbox.size }
    }
  end

  def page
    1
  end

  def discussions
    inbox.map do |discussion|
      data_for_discussion(discussion)
    end
  end

  private
  def data_for_discussion(discussion)
    {
      # TODO: Maybe expose a UUID instead?
      id: discussion.id,

      track_title: discussion.track_title,
      track_icon_url: discussion.track_icon_url,
      exercise_title: discussion.exercise_title,

      mentee_handle: discussion.student_handle,
      mentee_avatar_url: discussion.student_avatar_url,

      # TODO: Should this be discussioned_at?
      updated_at: discussion.created_at,

      # TODO: Add all these
      is_starred: true,
      posts_count: 4,

      # TODO: Rename this to web_url
      url: Exercism::Routes.mentor_discussion_url(discussion)
    }
  end
end
