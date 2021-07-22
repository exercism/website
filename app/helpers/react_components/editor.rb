module ReactComponents
  class Editor < ReactComponent
    initialize_with :solution

    def to_s
      super(
        "editor",
        {
          default_submissions: submissions,
          default_files: SerializeFiles.(solution.solution_files),
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
              introduction: introduction,
              assignment: SerializeExerciseAssignment.(solution),
              debugging_instructions: debugging_instructions,
              example_files: SerializeFiles.(example_files)
            },
            tests: solution.exercise.practice_exercise? ? { tests: solution.tests,
                                                            highlightjs_language: track.highlightjs_language } : nil,
            results: {
              average_test_duration: track.average_test_duration
            }
          },
          track: {
            title: track.title,
            slug: track.slug
          },
          exercise: {
            title: solution.exercise.title
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

    # TODO: (Required) remove this before launch
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
