require_relative './base_test_case'

module API
  class CommunitySolutionsControllerTest < API::BaseTestCase
    #########
    # INDEX #
    #########
    test "index should proxy params" do
      track = create :track
      exercise = create(:concept_exercise, track:)

      Solution::SearchCommunitySolutions.expects(:call).with(
        exercise,
        page: '5',
        order: "newest",
        criteria: "author",
        sync_status: :up_to_date,
        tests_status: nil,
        head_tests_status: nil
      ).returns(Solution.page(1))

      get api_track_exercise_community_solutions_path(
        track, exercise,
        page: 5,
        order: "newest",
        criteria: "author",
        up_to_date: "true",
        passed_tests: nil,
        not_passed_head_tests: "true"
      ), headers: @headers, as: :json

      assert_response :ok
    end

    test "head_tests_status filter is on by default" do
      track = create :track
      exercise = create(:concept_exercise, track:)

      Solution::SearchCommunitySolutions.expects(:call).with(
        exercise,
        page: '5',
        order: "newest",
        criteria: "author",
        sync_status: :up_to_date,
        tests_status: nil,
        head_tests_status: %i[not_queued queued passed]
      ).returns(Solution.page(1))

      get api_track_exercise_community_solutions_path(
        track, exercise,
        page: 5,
        order: "newest",
        criteria: "author",
        up_to_date: "true",
        passed_tests: nil,
        not_passed_head_tests: nil
      ), headers: @headers, as: :json

      assert_response :ok
    end

    test "index should search and return solutions" do
      track = create :track
      exercise = create(:concept_exercise, :random_slug, track:)
      solution_1 = create :concept_solution, exercise:, published_at: Time.current, num_stars: 11,
        published_iteration_head_tests_status: :queued
      create :iteration, solution: solution_1
      solution_2 = create :concept_solution, exercise:, published_at: Time.current, num_stars: 22,
        published_iteration_head_tests_status: :passed
      create :iteration, solution: solution_2
      create :concept_solution, published_at: Time.current, num_stars: 33

      exercise.update(num_published_solutions: 2)
      wait_for_opensearch_to_be_synced

      get api_track_exercise_community_solutions_path(
        track, exercise
      ), headers: @headers, as: :json

      assert_response :ok
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
