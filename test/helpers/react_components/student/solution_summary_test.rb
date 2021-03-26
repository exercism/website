require_relative "../react_component_test_case"

module Student
  class SolutionSummaryTest < ReactComponentTestCase
    test "component renders correctly" do
      track = create :track
      exercise = create :concept_exercise, track: track
      solution = create :concept_solution, exercise: exercise
      iteration = create :iteration, solution: solution

      component = ReactComponents::Student::SolutionSummary.new(solution).to_s

      assert_component(
        component,
        "student-solution-summary",
        {
          solution: SerializeSolutionForStudent.(solution),
          request: {
            endpoint: Exercism::Routes.api_solution_url(solution.uuid, sideload: [:iterations]),
            options: {
              initialData: {
                iterations: [SerializeIteration.(iteration)]
              }
            }
          },
          discussions: [],
          is_concept_exercise: true,
          links: {
            tests_passed_locally_article: "#",
            all_iterations: Exercism::Routes.track_exercise_iterations_path(track, exercise),
            community_solutions: "#",
            learn_more_about_mentoring_article: "#",
            mentoring_info: "#",
            complete_exercise: Exercism::Routes.complete_api_solution_url(solution.uuid),
            share_mentoring: "https://some.link/we/need/to-decide-on",
            request_mentoring: Exercism::Routes.new_track_exercise_mentor_request_path(solution.track, solution.exercise),
            pending_mentor_request: Exercism::Routes.track_exercise_mentor_request_path(solution.track, solution.exercise)
          }
        }
      )
    end

    test "link for in progress discussion" do
      track = create :track
      exercise = create :concept_exercise, track: track
      solution = create :concept_solution, exercise: exercise
      discussion = create :mentor_discussion, solution: solution

      component = ReactComponents::Student::SolutionSummary.new(solution).to_s
      data = component.gsub("&quot;", '"')
      url = Exercism::Routes.track_exercise_mentor_discussion_path(solution.track, solution.exercise, discussion)
      assert_includes data, %("in_progress_discussion":"#{url}")
    end
  end
end
