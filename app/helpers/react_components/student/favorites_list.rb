module ReactComponents
  module Student
    class FavoritesList < ReactComponent
      initialize_with :user, :params

      def to_s
        super("favorites-list", {
          request:,
          tracks: tracks_data,
          is_user_insider: user.insider?
        })
      end

      private
      def request
        {
          endpoint: Exercism::Routes.api_favorites_url,
          query: params.slice(*AssembleFavorites.keys),
          options: { initial_data: AssembleFavorites.(user, params) }
        }
      end

      def tracks_data
        # This is 2 OOM faster than using select or a join
        counts = Exercise.group('exercises.track_id').where(id: user.starred_solutions.pluck(:exercise_id)).count
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
