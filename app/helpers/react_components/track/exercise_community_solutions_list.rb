module ReactComponents
  module Track
    class ExerciseCommunitySolutionsList < ReactComponent
      initialize_with :exercise, :params

      def to_s
        super("track-exercise-community-solutions-list", { request:, tags: mock_tags })
      end

      private
      def request
        {
          endpoint: Exercism::Routes.api_track_exercise_community_solutions_url(exercise.track, exercise),
          query: search_params,
          options: { initial_data: data }
        }
      end

      def data
        AssembleExerciseCommunitySolutionsList.(exercise, search_params)
      end

      MOCK_TAGS = [
        'construct:char',
        'construct:class',
        'construct:implicit-conversion',
        'construct:int',
        'construct:integral-number',
        'construct:invocation',
        'construct:lambda',
        'construct:linq',
        'construct:method',
        'construct:number',
        'construct:parameter',
        'construct:return',
        'construct:string',
        'construct:using-directive',
        'construct:visibility-modifiers',
        'paradigm:functional',
        'paradigm:object-oriented',
        'technique:higher-order-functions',
        'uses:Enumerable.GroupBy'
      ].freeze

      # TODO: adjust this
      # def tags
      #   Exercise.for('csharp', 'two-fer').tags.distinct.select(:tag).
      #     group_by(&:category).map { |c, tags| [c.titleize, tags.map(&:tag)] }.
      #     to_h
      # end

      def group_tags(tag_list)
        grouped_tags = {}

        tag_list.each do |tag|
          key, = tag.split(':', 2)
          grouped_tags[key] ||= []
          grouped_tags[key] << tag
        end

        grouped_tags.transform_keys(&:capitalize)
      end

      def mock_tags = group_tags(MOCK_TAGS)

      memoize
      def search_params
        params.permit(*AssembleExerciseCommunitySolutionsList.permitted_params).to_h
      end
    end
  end
end
