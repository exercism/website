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
          introduction_html: exercise.introduction_html,
          tasks: exercise.tasks,
          config: {
            title: exercise.config[:title],
            description: exercise.config[:description],
            project_type: exercise.config[:project_type],
            tests_type: exercise.config[:tests_type]
          },
          test_results: submission&.test_results
        },
        solution: {
          uuid: solution.uuid,
          status: solution.status
        },
        test_results: submission&.test_results,
        code: {
          # rename to `value` or similar? code.code is a bit confusing
          code: submission ? submission.code : exercise.stub,
          stored_at: submission&.created_at,
          readonly_ranges:
        },
        links: {
          post_submission: Exercism::Routes.api_bootcamp_solution_submissions_url(solution_uuid: solution.uuid, only_path: true),
          complete_solution: Exercism::Routes.complete_api_bootcamp_solution_url(solution.uuid, only_path: true),
          projects_index: Exercism::Routes.bootcamp_projects_url(only_path: true)
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
