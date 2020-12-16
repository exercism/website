module ReactComponents
  class Editor < ReactComponent
    initialize_with :solution

    def to_s
      super(
        "editor",
        {
          exercise_path: Exercism::Routes.track_exercise_path(solution.track, solution.exercise),
          track_title: solution.track.title,
          exercise_title: solution.exercise.title,
          introduction: introduction,
          instructions: instructions,
          example_solution: solution.exercise.send(:git).example,
          endpoint: Exercism::Routes.api_solution_submissions_path(
            solution.uuid,
            auth_token: solution.user.auth_tokens.first.to_s
          ),
          submission: SerializeSubmission.(solution.submissions.last),
          files: SerializeFiles.(solution.editor_solution_files),
          language: solution.editor_language
        }
      )
    end

    private
    memoize
    def introduction
      ParseMarkdown.(solution.introduction)
    end

    memoize
    def instructions
      ParseMarkdown.(solution.instructions)
    end
  end
end
