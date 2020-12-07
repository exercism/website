class SerializeMentorInbox
  include Mandate

  initialize_with :inbox

  def call
    {
      results: requests,
      meta: { current: page, total: inbox.size }
    }
  end

  def page
    1
  end

  def requests
    inbox.map do |request|
      data_for_request(request)
    end
  end

  private
  def data_for_request(request)
    {
      # TODO: Maybe expose a UUID instead?
      id: request.id,

      track_title: request.track_title,
      track_icon_url: request.track_icon_url,
      exercise_title: request.exercise_title,

      mentee_handle: request.student_handle,
      mentee_avatar_url: request.student_avatar_url,

      # TODO: Should this be requested_at?
      updated_at: request.created_at,

      # TODO: Add all these
      is_starred: true,
      posts_count: 4,

      # TODO: Rename this to web_url
      # TODO: Maybe expose a UUID instead?
      url: Exercism::Routes.mentor_discussion_url(request)
    }
  end
end
