require_relative "../react_component_test_case"

module Student
  class ConceptMapTest < ReactComponentTestCase
    test "component renders correctly" do
      track = create :track
      exercise = create :concept_exercise, track: track
      solution = create :concept_solution, exercise: exercise
      iteration = create :iteration, solution: solution

      component = ReactComponents::Student::SolutionSummary.new(iteration).to_s

      assert_component(
        component,
        "student-solution-summary",
        {
          solution_id: solution.uuid,
          request: {
            endpoint: Exercism::Routes.temp_solution_url(solution.uuid),
            options: {
              initialData: {
                latest_iteration: SerializeIteration.(iteration)
              }
            }
          },
          is_concept_exercise: true,
          links: {
            tests_passed_locally_article: "#",
            all_iterations: Exercism::Routes.track_exercise_iterations_path(track, exercise),
            community_solutions: "#",
            learn_more_about_mentoring_article: "#"
          }
        }
      )
    end
  end
end
