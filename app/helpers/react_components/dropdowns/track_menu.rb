module ReactComponents
  module Dropdowns
    class TrackMenu < ReactComponent
      initialize_with :track

      def to_s
        return "" unless user_signed_in?

        super("dropdowns-track-menu", {
          track: SerializeTrack.(track, user_track),
          links:
        })
      end

      private
      memoize
      def user_track
        UserTrack.for(current_user, track)
      end

      def links
        hash = {
          repo: track.repo_url,
          documentation: Exercism::Routes.track_docs_url(track),
          build_status: Exercism::Routes.track_build_path(track)
        }
        return hash if user_track.external?

        if user_track.course?
          hash[:activate_practice_mode] = activate_practice_mode_url
          hash[:activate_learning_mode] = activate_learning_mode_url
        end

        hash[:reset] = Exercism::Routes.reset_api_track_url(track)
        hash[:leave] = Exercism::Routes.leave_api_track_url(track)

        hash
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
