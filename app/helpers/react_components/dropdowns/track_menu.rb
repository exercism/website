module ReactComponents
  module Dropdowns
    class TrackMenu < ReactComponent
      initialize_with :track

      def to_s
        return if user_track.blank? || user_track.external?

        super("dropdowns-track-menu", {
          track: {
            title: track.title
          },
          links: links
        })
      end

      private
      memoize
      def user_track
        UserTrack.for(current_user, track)
      end

      def links
        {
          repo: track.repo_url,
          documentation: Exercism::Routes.track_docs_url(track),
          activate_practice_mode: activate_practice_mode_url,
          activate_learning_mode: activate_learning_mode_url,
          reset: Exercism::Routes.reset_api_track_url(track),
          leave: Exercism::Routes.leave_api_track_url(track)
        }
      end

      def activate_practice_mode_url
        return if user_track.practice_mode?

        Exercism::Routes.activate_practice_mode_api_track_url(track)
      end

      def activate_learning_mode_url
        return unless user_track.practice_mode?

        Exercism::Routes.activate_learning_mode_api_track_url(track)
      end
    end
  end
end
