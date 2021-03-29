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
        page: '5'
      ).returns(Solution.page(1))

      get api_track_exercise_community_solutions_path(
        track, exercise,
        page: 5
      ), headers: @headers, as: :json

      assert_response :success
    end

    test "index should search and return solutions" do
      track = create :track
      exercise = create :concept_exercise, :random_slug, track: track
      create :concept_solution, exercise: exercise
      create :concept_solution, exercise: exercise
      create :concept_solution

      get api_track_exercise_community_solutions_path(
        track, exercise
      ), headers: @headers, as: :json

      assert_response :success
      expected = {
        solutions: SerializePaginatedCollection.(
          exercise.solutions.page(1),
          serializer: SerializeCommunitySolutions
        )
      }.to_json
      assert_equal expected, response.body
    end
  end
end
