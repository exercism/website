class MentorInbox < ViewComponent
  def render(conversations_request, tracks_request)
    react_component("mentor-inbox", {
                      conversations_request: conversations_request,
                      tracks_request: tracks_request
                    })
  end
end
