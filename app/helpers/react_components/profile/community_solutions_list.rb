module ReactComponents
  module Profile
    class CommunitySolutionsList < ReactComponent
      initialize_with :user, :params

      def to_s
        super("profile-community-solutions-list", {
          request:,
          tracks: tracks_data
        })
      end

      private
      def request
        {
          endpoint: Exercism::Routes.api_profile_solutions_url(user),
          query: params.slice(*AssembleProfileSolutionsList.keys),
          options: { initial_data: AssembleProfileSolutionsList.(user, params) }
        }
      end

      def tracks_data
        # This is 2 OOM faster than using select or a join
        counts = Exercise.group('exercises.track_id').where(id: user.solutions.published.pluck(:exercise_id)).count
        tracks = ::Track.where(id: counts.keys).order(:title)

        [
          SerializeTrackForSelect::ALL_TRACK.merge(num_solutions: counts.values.sum),
          *tracks.map do |track|
            SerializeTrackForSelect.(track).merge(num_solutions: counts[track.id])
          end
        ]
      end
    end
  end
end
