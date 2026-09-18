module ReactComponents
  module Student
    class UpdateExerciseNotice < ReactComponent
      initialize_with :solution, :english_docs

      def to_s
        super(
          "student-update-exercise-notice",
          {
            docs_for_newer_version: !english_docs && solution.docs_for_newer_version?,
            links: {
              diff: Exercism::Routes.diff_api_solution_url(solution.uuid),
              english: english_docs_url
            }
          }
        )
      end

      private
      attr_reader :solution, :english_docs

      def english_docs_url
        uri = Addressable::URI.parse(request.original_url)
        uri.query_values = (uri.query_values || {}).merge("exercise_locale" => "en")
        uri.to_s
      end
    end
  end
end
