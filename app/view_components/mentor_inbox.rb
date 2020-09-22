class MentorInbox < ViewComponent
  include Mandate

  initialize_with :conversations_request, :tracks_request, :sort_options

  def to_s
    react_component("mentor-inbox", {
                      conversations_request: conversations_request,
                      tracks_request: tracks_request,
                      sort_options: sort_options
                    })
  end
end
