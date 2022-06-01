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
        counts = user.solutions.joins(:exercise).published.group('exercises.track_id').count
        tracks = ::Track.where(id: counts.keys).index_by(&:id)

        [
          SerializeTrackForSelect::ALL_TRACK.merge(num_solutions: counts.values.sum),
          *counts.map do |track_id, count|
            SerializeTrackForSelect.(tracks[track_id]).merge(num_solutions: count)
          end
        ]
      end
    end
  end
end
