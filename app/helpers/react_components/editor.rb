module ReactComponents
  class Editor < ReactComponent
    initialize_with :solution

    def to_s
      super(
        "editor",
        {
          exercise_path: Exercism::Routes.track_exercise_path(track, solution.exercise),
          track_title: track.title,
          exercise_title: solution.exercise.title,
          introduction: introduction,
          # TODO: This should be using the solution sha, not the exercise sha
          assignment: SerializeExerciseAssignment.(solution.exercise),
          tests: solution.exercise.practice_exercise? ? solution.tests : nil,
          debugging_instructions: debugging_instructions,
          example_files: SerializeFiles.(example_files),
          endpoint: Exercism::Routes.api_solution_submissions_url(
            solution.uuid,
            auth_token: solution.user.auth_tokens.first.to_s
          ),
          submission: SerializeSubmission.(solution.submissions.last),
          files: SerializeFiles.(solution.solution_files),
          ace_language: track.ace_language,
          highlightjs_language: track.highlightjs_language,
          average_test_duration: track.average_test_duration,
          storage_key: solution.uuid,
          config: {
            tab_size: track.indent_size,
            use_soft_tabs: track.indent_style == :space
          }
        }
      )
    end

    private
    memoize
    def introduction
      Markdown::Parse.(solution.introduction)
    end

    memoize
    def instructions
      Markdown::Parse.(solution.instructions)
    end

    memoize
    def debugging_instructions
      return if track.debugging_instructions.blank?

      Markdown::Parse.(track.debugging_instructions)
    end

    # TODO: remove this before launch
    def example_files
      return solution.exercise.send(:git).exemplar_files if solution.exercise.concept_exercise?

      solution.exercise.send(:git).example_files
    end

    memoize
    def track
      solution.track
    end
  end
end
