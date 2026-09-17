module Exercism
  # Mirrored in app/javascript/components/common/videos.ts: the same video is
  # rendered from haml on the exercise page and from React in the editor.
  # Hosted on Mux; the values are [playback_id, title, poster]. The poster is
  # an app/images path, served from our assets host rather than Mux's, which
  # sends no CORP header and so is blocked on the cross-origin isolated editor.
  def self.hello_world_video
    ["02J8pJ003aCb9gRhNRKZ5v4VH7o9DVQCUY4TA01S43JXwg", "Welcome to Hello, World!", "videos/hello-world-poster.jpg"]
  end
end
