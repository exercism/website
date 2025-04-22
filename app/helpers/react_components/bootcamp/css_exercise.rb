module ReactComponents
  class Bootcamp::CSSExercise < ReactComponent
    initialize_with :solution

    def to_s
      super(id, data)
    end

    def id = "bootcamp-css-exercise-page"

    def data
      {
        project: { slug: project.slug },
        exercise: {
          id: exercise.id,
          slug: exercise.slug,
          title: exercise.title,
          introduction_html: exercise.introduction_html,
          checks: exercise.config[:checks] || [],
          config: {
            title: exercise.config[:title],
            description: exercise.config[:description],
            allowed_properties: exercise.config[:allowed_properties],
            disallowed_properties: exercise.config[:disallowed_properties],
            expected:
          }
        },
        solution: {
          uuid: solution.uuid,
          status: solution.status,
          passed_basic_tests: solution.passed_basic_tests?
        },
        test_results: submission&.test_results,
        code: {
          stub: {
            css: exercise.stub("css"),
            html: exercise.stub("html")
          },
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
          bootcamp_level_url: Exercism::Routes.bootcamp_level_url("idx"),
          custom_fns_dashboard: Exercism::Routes.bootcamp_custom_functions_url
        }
      }
    end

    def expected
      {
        html: exercise.example("html"),
        css: exercise.example("css")
      }
    end

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
