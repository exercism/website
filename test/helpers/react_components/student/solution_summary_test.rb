require_relative "../react_component_test_case"

class ReactComponents::Student::SolutionSummaryTest < ReactComponentTestCase
  test "component renders correctly" do
    track = create :track
    exercise = create(:concept_exercise, track:)
    solution = create(:concept_solution, exercise:)
    iteration = create(:iteration, solution:)

    component = ReactComponents::Student::SolutionSummary.new(solution).to_s

    assert_component(
      component,
      "student-solution-summary",
      {
        solution: SerializeSolution.(solution),
        track: {
          title: solution.track.title,
          median_wait_time: solution.track.median_wait_time
        },
        request: {
          endpoint: Exercism::Routes.api_solution_url(solution.uuid, sideload: [:iterations]),
          options: {
            initialData: {
              iterations: [SerializeIteration.(iteration)]
            }
          }
        },
        discussions: [],
        exercise: {
          title: exercise.title,
          type: 'concept'
        },
        links: {
          tests_pass_locally_article: Exercism::Routes.doc_path(:using, "solving-exercises/tests-pass-locally"),
          all_iterations: Exercism::Routes.track_exercise_iterations_path(track, exercise),
          community_solutions: Exercism::Routes.track_exercise_solutions_path(track, exercise),
          learn_more_about_mentoring_article: Exercism::Routes.doc_path(:using, "feedback"),
          mentoring_info: Exercism::Routes.doc_path(:using, "feedback/guide-to-being-mentored"),
          complete_exercise: Exercism::Routes.complete_api_solution_url(solution.uuid),
          share_mentoring: solution.external_mentoring_request_url,
          request_mentoring: Exercism::Routes.new_track_exercise_mentor_request_path(solution.track, solution.exercise),
          pending_mentor_request: Exercism::Routes.track_exercise_mentor_request_path(solution.track, solution.exercise)
        }
      }
    )
  end

  test "link for in progress discussion" do
    track = create :track
    exercise = create(:concept_exercise, track:)
    solution = create(:concept_solution, exercise:)
    discussion = create(:mentor_discussion, solution:)

    component = ReactComponents::Student::SolutionSummary.new(solution).to_s
    data = component.gsub("&quot;", '"')
    url = Exercism::Routes.track_exercise_mentor_discussion_path(solution.track, solution.exercise, discussion)
    assert_includes data, %("in_progress_discussion":"#{url}")
  end

  test "exercise type" do
    solution = create :concept_solution
    component = ReactComponents::Student::SolutionSummary.new(solution).to_s
    assert_includes component.to_s, ERB::Util.unwrapped_html_escape('"type":"concept"')

    solution = create :practice_solution
    component = ReactComponents::Student::SolutionSummary.new(solution).to_s
    assert_includes component.to_s, ERB::Util.unwrapped_html_escape('"type":"practice"')

    exercise = create :practice_exercise, slug: "hello-world"
    solution = create(:practice_solution, exercise:)
    component = ReactComponents::Student::SolutionSummary.new(solution).to_s
    assert_includes component.to_s, ERB::Util.unwrapped_html_escape('"type":"tutorial"')
  end
end
