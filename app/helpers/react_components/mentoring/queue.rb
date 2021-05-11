module ReactComponents
  module Mentoring
    class Queue < ReactComponent
      extend Mandate::Memoize

      def initialize(mentor, params)
        super()

        @mentor = mentor
        @params = params
      end

      def to_s
        super(
          "mentoring-queue",
          {
            queue_request: queue_request,
            tracks_request: tracks_request,
            default_track: default_track,
            default_exercise: default_exercise,
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
      attr_reader :mentor, :params

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
        last_viewed_slug = params[:track_slug] || mentor.
          track_mentorships.
          joins(:track).
          where(last_viewed: true).
          pick('tracks.slug')
        track_data = tracks_data.find { |td| td[:id] == last_viewed_slug } || tracks_data.first

        track_data.merge(exercises: exercises_data(track_data[:id]))
      end

      def default_exercise
        exercises_data(default_track[:id]).find { |ed| ed[:slug] == params[:exercise_slug] }
      end

      def queue_request
        {
          endpoint: Exercism::Routes.api_mentoring_requests_path,
          query: {
            order: params[:order],
            criteria: params[:criteria],
            page: params[:page],
            track_slug: default_track[:id],
            exercise_slug: default_exercise.try(:[], :slug)
          }.compact
        }
      end

      def exercises_data(track_id)
        ::Mentor::Request::RetrieveExercises.(mentor, track_id)
      end

      memoize
      def tracks_data
        SerializeTracksForMentoring.(mentor.mentored_tracks, mentor: mentor)
      end
    end
  end
end
