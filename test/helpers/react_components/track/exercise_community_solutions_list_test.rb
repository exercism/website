require_relative "../react_component_test_case"
class ReactComponents::Track::ExerciseCommunitySolutionsListTest < ReactComponentTestCase
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
        },
        tags: {}
      }
    )
  end
end
