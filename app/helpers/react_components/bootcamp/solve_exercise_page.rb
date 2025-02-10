module ReactComponents
  class Bootcamp::SolveExercisePage < ReactComponent
    initialize_with :solution

    def to_s
      super(id, data)
    end

    def id = "bootcamp-solve-exercise-page"

    def data
      {
        project: { slug: project.slug },
        exercise: {
          id: exercise.id,
          slug: exercise.slug,
          title: exercise.title,
          introduction_html: exercise.introduction_html,
          tasks: exercise.tasks,
          config: {
            title: exercise.config[:title],
            description: exercise.config[:description],
            project_type: exercise.config[:project_type],
            tests_type: exercise.config[:tests_type],
            interpreter_options: exercise.config[:interpreter_options],
            stdlib_functions: exercise.config[:stdlib_functions],
            exercise_functions: exercise.config[:exercise_functions]
          },
          test_results: submission&.test_results
        },
        solution: {
          uuid: solution.uuid,
          status: solution.status,
          passed_basic_tests: solution.passed_basic_tests,
          passed_bonus_tests: solution.passed_bonus_tests
        },
        test_results: submission&.test_results,
        code: {
          stub: exercise.stub,
          code: solution.code,
          stored_at: submission&.created_at,
          readonly_ranges:,
          default_readonly_ranges: exercise.readonly_ranges
        },
        links: {
          post_submission: Exercism::Routes.api_bootcamp_solution_submissions_url(solution_uuid: solution.uuid, only_path: true),
          complete_solution: Exercism::Routes.complete_api_bootcamp_solution_url(solution.uuid, only_path: true),
          projects_index: Exercism::Routes.bootcamp_projects_url(only_path: true),
          dashboard_index: Exercism::Routes.bootcamp_dashboard_url(only_path: true),
          bootcamp_level_url: Exercism::Routes.bootcamp_level_url("idx")
        }
      }
    end

    private
    def readonly_ranges
      return submission.readonly_ranges if submission

      exercise.readonly_ranges
    end

    memoize
    def submission = solution.submissions.last

    delegate :exercise, to: :solution
    delegate :project, to: :exercise
  end
end
