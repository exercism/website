module ReactComponents
  module Profile
    class ContributionsSummary < ReactComponent
      # We normally proxy this to the current renderng session
      # but for this situation as we're accessing data, not just to_s
      # we'll just include this module manually in the class.
      include ActionView::Helpers::NumberHelper

      initialize_with :user

      def to_s
        super("profile-contributions-summary", data)
      end

      # This should take <10ms so it doesn't need caching, which is
      # good because there's a lot of data to try and work out
      # cache invalidation for here.
      def data
        {
          tracks: [
            {
              id: "all",
              title: "All",
              icon_url: "ICON",
              categories: categories_data
            }
          ].concat(tracks.map { |track| data_for_track(track) })
        }
      end

      def data_for_track(track)
        {
          id: track.slug,
          title: track.title,
          icon_url: track.icon_url,
          categories: categories_data(track.id)
        }
      end

      def categories_data(track_id = nil)
        [
          {
            id: :publishing,
            reputation: num_reputation_points(:publishing, track_id),
            metric: publishing_metric(track_id)
          },
          {
            id: :mentoring,
            reputation: num_reputation_points(:mentoring, track_id),
            metric: mentoring_metric(track_id)
          },
          {
            id: :authoring,
            reputation: num_reputation_points(:authoring, track_id),
            metric: authoring_metric(track_id)
          },
          {
            id: :building,
            reputation: num_reputation_points(:building, track_id),
            metric: building_metric(track_id)
          },
          {
            id: :maintaining,
            reputation: num_reputation_points(:maintaining, track_id),
            metric: maintaining_metric(track_id)
          },
          {
            id: :other,
            reputation: num_reputation_points(:misc, track_id)
          }
        ]
      end

      private
      def publishing_metric(track_id = nil)
        c = track_id ? published_solutions[track_id] : published_solutions.values.sum
        "#{number_with_delimiter(c)} #{'solution'.pluralize(c)}"
      end

      def authoring_metric(track_id = nil)
        c = track_id ? authorships[track_id] : authorships.values.sum
        "#{number_with_delimiter(c)} #{'exercise'.pluralize(c)}"
      end

      def mentoring_metric(track_id = nil)
        c = track_id ? mentored_students[track_id] : mentored_students.values.sum
        "#{number_with_delimiter(c)} #{'student'.pluralize(c)}"
      end

      def building_metric(track_id = nil)
        c = num_reputation_occurrences(:building, track_id).to_i
        "#{number_with_delimiter(c)} #{'PR'.pluralize(c)} created"
      end

      def maintaining_metric(track_id = nil)
        c = num_reputation_occurrences(:maintaining, track_id).to_i
        "#{number_with_delimiter(c)} #{'PR'.pluralize(c)} reviewed"
      end

      def num_reputation_points(requested_category, requested_track_id = nil)
        requested_category = requested_category.to_s
        reputation_points.select do |(track_id, category), _|
          category == requested_category && (requested_track_id ? track_id == requested_track_id : true)
        end.values.sum
      end

      def num_reputation_occurrences(requested_category, requested_track_id)
        requested_category = requested_category.to_s
        reputation_occurrences.select do |(track_id, category), _|
          category == requested_category && (requested_track_id ? track_id == requested_track_id : true)
        end.values.sum
      end

      memoize
      def tracks
        ::Track.where(id: reputation_occurrences.keys.map(&:first).compact)
      end

      memoize
      def published_solutions
        user.solutions.published.joins(:exercise).group("exercises.track_id").count
      end

      memoize
      def authorships
        q_1 = Exercise.where(id: user.authorships.select(:exercise_id))
        q_2 = Exercise.where(id: user.contributorships.select(:exercise_id))
        q_1.or(q_2).distinct(:id).group(:track_id).count
      end

      memoize
      def mentored_students
        user.mentor_discussions.joins(solution: :exercise).group('exercises.track_id').
          select('solutions.user_id').distinct.count
      end

      memoize
      def reputation_points
        @user.reputation_tokens.group(:track_id, :category).sum(:value)
      end

      memoize
      def reputation_occurrences
        @user.reputation_tokens.group(:track_id, :category).count
      end
    end
  end
end
