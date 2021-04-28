module ReactComponents
  module Dropdowns
    class TrackMenu < ReactComponent
      initialize_with :track

      def to_s
        super("dropdowns-track-menu", {
          track: {
            title: track.title
          },
          links: links
        })
      end

      private
      def user_track
        UserTrack.for!(current_user, track)
      end

      def links
        {
          repo: track.repo_url,
          documentation: Exercism::Routes.track_docs_url(track),
          practice: Exercism::Routes.activate_practice_mode_api_user_track_url(user_track),
          reset: Exercism::Routes.reset_api_user_track_url(user_track),
          leave: Exercism::Routes.leave_api_user_track_url(user_track)
        }
      end
    end
  end
end
