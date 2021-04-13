module ReactComponents
  module Profile
    class CommunitySolutionsList < ReactComponent
      initialize_with :user, :solutions

      def to_s
        super("profile-community-solutions-list", {
          request: request,
          tracks: tracks_data
        })
      end

      private
      def request
        {
          endpoint: Exercism::Routes.api_profile_solutions_url(user),
          query: { order: "newest_first" },
          options: { initial_data: data }
        }
      end

      def tracks_data
        counts = @user.solutions.joins(:exercise).published.group('exercises.track_id').count
        tracks = ::Track.where(id: counts.keys).index_by(&:id)

        data = counts.map do |track_id, count|
          track = tracks[track_id]

          { id: track.slug, title: track.title, num_solutions: count, icon_url: track.icon_url }
        end

        data.unshift(
          id: nil, title: "All",
          num_solutions: counts.values.sum,
          icon_url: ::Track.first.icon_url # TODO
        )

        data
      end

      def data
        SerializePaginatedCollection.(
          @solutions,
          serializer: SerializeCommunitySolutions,
          meta: {
            unscoped_total: @user.solutions.published.count
          }
        )
      end
    end
  end
end
