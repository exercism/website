require_relative './base_test_case'

module API
  class CommunitySolutionsControllerTest < API::BaseTestCase
    #########
    # INDEX #
    #########
    test "index should proxy params" do
      track = create :track
      exercise = create :concept_exercise, track: track

      Solution::SearchCommunitySolutions.expects(:call).with(
        exercise,
        criteria: "author",
        page: '5'
      ).returns(Solution.page(1))

      get api_track_exercise_community_solutions_path(
        track, exercise,
        page: 5,
        criteria: "author"
      ), headers: @headers, as: :json

      assert_response :success
    end

    test "index should search and return solutions" do
      track = create :track
      exercise = create :concept_exercise, :random_slug, track: track
      solution_1 = create :concept_solution, exercise: exercise, published_at: Time.current
      create :iteration, solution: solution_1
      solution_2 = create :concept_solution, exercise: exercise, published_at: Time.current
      create :iteration, solution: solution_2
      create :concept_solution, published_at: Time.current

      get api_track_exercise_community_solutions_path(
        track, exercise
      ), headers: @headers, as: :json

      assert_response :success
      expected = SerializePaginatedCollection.(
        exercise.solutions.page(1),
        serializer: SerializeCommunitySolutions,
        meta: {
          unscoped_total: 2
        }
      ).to_json
      assert_equal expected, response.body
    end
  end
end
