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
            queue_request:,
            tracks_request:,
            default_track:,
            default_exercise:,
            sort_options:,
            links: {
              tracks: Exercism::Routes.api_mentoring_tracks_url,
              update_tracks: Exercism::Routes.api_mentoring_tracks_url
            }
          }
        )
      end

      private
      attr_reader :mentor, :params

      def sort_options
        [
          { value: "", label: I18n.t("components.mentoring.queue.sort_options.oldest_first") },
          { value: "recent", label: I18n.t("components.mentoring.queue.sort_options.recent_first") }
        ]
      end

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
        track_data = tracks_data.find { |td| td[:slug] == last_viewed_slug } || tracks_data.first

        track_data.merge(exercises: exercises_data(track_data[:slug]))
      end

      def default_exercise
        exercises_data(default_track[:slug]).find { |ed| ed[:slug] == params[:exercise_slug] }
      end

      def queue_request
        query = params.merge(
          track_slug: default_track[:slug],
          exercise_slug: default_exercise.try(:[], :slug)
        ).compact

        {
          endpoint: Exercism::Routes.api_mentoring_requests_path,
          query:,
          options: {
            initial_data: AssembleMentorRequests.(mentor, query)
          }
        }
      end

      def exercises_data(track_slug)
        @exercises_data ||= {}
        @exercises_data[track_slug] ||= ::Mentor::Request::RetrieveExercises.(mentor, track_slug)
      end

      memoize
      def tracks_data
        # Cope with the mentor not having any tracks they mentor
        # TODO: It might be better to redirect to a different onboarding
        # page in this situation
        tracks = mentor.mentored_tracks.presence || ::Track.where(id: ::Track.active.pick(:id))
        SerializeTracksForMentoring.(tracks, mentor)
      end
    end
  end
end
