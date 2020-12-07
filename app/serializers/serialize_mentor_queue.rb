class SerializeMentorQueue
  include Mandate

  initialize_with :queue

  def call
    {
      results: requests,
      meta: { current: page, total: queue.size }
    }
  end

  def page
    1
  end

  def requests
    queue.map do |request|
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

      mentee_handle: request.user_handle,
      mentee_avatar_url: request.user_avatar_url,

      # TODO: Should this be requested_at?
      updated_at: request.created_at,

      # TODO: Add all these
      is_starred: true,
      have_mentored_previously: true,
      status: "First timer",
      tooltip_url: "#",

      # TODO: Rename this to web_url
      # TODO: Maybe expose a UUID instead?
      url: Exercism::Routes.mentor_request_url(request)
    }
  end
end
