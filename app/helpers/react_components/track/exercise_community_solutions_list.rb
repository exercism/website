module ReactComponents
  module Track
    class ExerciseCommunitySolutionsList < ReactComponent
      initialize_with :exercise, :params

      def to_s
        super("track-exercise-community-solutions-list", { request:, tags: })
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

      memoize
      def search_params
        params.permit(*AssembleExerciseCommunitySolutionsList.permitted_params).to_h
      end

      memoize
      def tags
        exercise.tags.
          reject { |t| t.category == "uses" }.
          group_by(&:category).
          map { |category, tags| [category.titleize, tags.map(&:tag)] }.
          filter { |c, _| TAG_CATEGORY_ORDER.include?(c) }.
          sort_by { |(c, _)| TAG_CATEGORY_ORDER.index(c) }.
          to_h
      rescue StandardError
        nil
      end

      TAG_CATEGORY_ORDER = %w[Technique Paradigm Construct].freeze
      private_constant :TAG_CATEGORY_ORDER
    end
  end
end
