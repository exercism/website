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
        page: '5',
        order: "newest",
        criteria: "author",
        tests_status: "passed",
        mentoring_status: "requested",
        sync_status: "up_to_date"
      ).returns(Solution.page(1))

      get api_track_exercise_community_solutions_path(
        track, exercise,
        page: 5,
        order: "newest",
        criteria: "author",
        tests_status: "passed",
        mentoring_status: "requested",
        sync_status: "up_to_date"
      ), headers: @headers, as: :json

      assert_response :success
    end

    test "index should search and return solutions" do
      track = create :track
      exercise = create :concept_exercise, :random_slug, track: track
      solution_1 = create :concept_solution, exercise: exercise, published_at: Time.current, num_stars: 11
      create :iteration, solution: solution_1
      solution_2 = create :concept_solution, exercise: exercise, published_at: Time.current, num_stars: 22
      create :iteration, solution: solution_2
      create :concept_solution, published_at: Time.current, num_stars: 33

      wait_for_opensearch_to_be_synced

      get api_track_exercise_community_solutions_path(
        track, exercise
      ), headers: @headers, as: :json

      assert_response :success
      expected = SerializePaginatedCollection.(
        exercise.solutions.order(id: :desc).page(1),
        serializer: SerializeCommunitySolutions,
        meta: {
          unscoped_total: 2
        }
      ).to_json
      assert_equal expected, response.body
    end
  end
end
