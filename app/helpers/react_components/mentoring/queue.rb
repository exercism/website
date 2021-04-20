module ReactComponents
  module Mentoring
    class Queue < ReactComponent
      extend Mandate::Memoize

      def initialize(mentor)
        super()

        @mentor = mentor
      end

      def to_s
        super(
          "mentoring-queue",
          {
            queue_request: queue_request,
            tracks_request: tracks_request,
            default_track: default_track,
            sort_options: SORT_OPTIONS,
            links: {
              tracks: Exercism::Routes.api_mentoring_tracks_url,
              update_tracks: Exercism::Routes.api_mentoring_tracks_url
            }
          }
        )
      end

      SORT_OPTIONS = [
        { value: "recent", label: "Sort by Most Recent" },
        { value: "exercise", label: "Sort by Exercise" },
        { value: "student", label: "Sort by Student" }
      ].freeze
      private_constant :SORT_OPTIONS

      private
      attr_reader :mentor

      def tracks_request
        {
          endpoint: Exercism::Routes.mentored_api_mentoring_tracks_url,
          options: {
            initial_data: {
              tracks: tracks_data
            }
          }
        }
      end

      def default_track
        last_viewed_slug = mentor.track_mentorships.joins(:track).where(last_viewed: true).pick('tracks.slug')
        track_data = tracks_data.find { |td| td[:id] == last_viewed_slug }
        track_data ||= tracks_data.first

        track_data.merge(
          exercises: ::Mentor::Request::RetrieveExercises.(mentor, track_data[:id])
        )
      end

      def queue_request
        {
          endpoint: Exercism::Routes.api_mentoring_requests_path
        }
      end

      memoize
      def tracks_data
        SerializeTracksForMentoring.(mentor.mentored_tracks, mentor: mentor)
      end
    end
  end
end
