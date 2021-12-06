require_relative "../react_component_test_case"

module ReactComponents::Track
  class ExerciseCommunitySolutionsListTest < ReactComponentTestCase
    test "mentoring request renders correctly" do
      exercise = create :practice_exercise
      component = ReactComponents::Track::ExerciseCommunitySolutionsList.new(exercise, params)

      assert_component(
        render(component),
        "track-exercise-community-solutions-list",
        {
          request: {
            endpoint: "https://test.exercism.org/api/v2/tracks/ruby/exercises/bob/community_solutions",
            query: {},
            options: { initial_data: {
              results: [],
              meta: { current_page: 1,
                      total_count: 0,
                      total_pages: 0,
                      unscoped_total: 0 }
            } }
          }
        }
      )
    end

    test "mentoring request parses boolean params" do
      exercise = create :practice_exercise
      component = ReactComponents::Track::ExerciseCommunitySolutionsList.new(exercise, ActionController::Parameters.new({
        up_to_date: "true",
        passed_tests: "true",
        not_passed_head_tests: "true",
        page: 5
      }))

      assert_component(
        render(component),
        "track-exercise-community-solutions-list",
        {
          request: {
            endpoint: "https://test.exercism.org/api/v2/tracks/ruby/exercises/bob/community_solutions",
            query: {
              "page": 5,
              "up_to_date": true,
              "passed_tests": true,
              "not_passed_head_tests": true
            },
            options: { initial_data: {
              results: [],
              meta: { current_page: 1,
                      total_count: 0,
                      total_pages: 0,
                      unscoped_total: 0 }
            } }
          }
        }
      )
    end
  end
end
