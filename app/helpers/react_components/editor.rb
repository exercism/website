module ReactComponents
  class Editor < ReactComponent
    initialize_with :solution

    def to_s
      super(
        "editor",
        {
          default_submissions: submissions,
          default_files: SerializeEditorFiles.(solution.files_for_editor),
          default_settings: {
            tab_size: track.indent_size,
            use_soft_tabs: track.indent_style == :space
          },
          autosave: {
            key: solution.uuid,
            save_interval: 500
          },
          panels: {
            instructions: {
              introduction:,
              assignment: SerializeExerciseAssignment.(solution),
              debugging_instructions:
            },
            tests: solution.exercise.practice_exercise? ? {
              test_files: SerializeFiles.(solution.test_files),
              highlightjs_language: track.highlightjs_language
            } : nil,
            results: {
              test_runner: {
                average_test_duration: track.average_test_duration
              }
            }
          },
          track: {
            title: track.title,
            slug: track.slug
          },
          exercise: {
            title: solution.exercise.title,
            slug: solution.exercise.slug
          },
          links: {
            run_tests: Exercism::Routes.api_solution_submissions_url(solution.uuid),
            back: Exercism::Routes.track_exercise_path(track, solution.exercise)
          }
        }
      )
    end

    private
    def submissions
      submission = solution.latest_submission

      submission ? [SerializeSubmission.(submission)] : []
    end

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

    memoize
    def track
      solution.track
    end
  end
end
