require_relative './base_test_case'

module API
  class CommunitySolutionsControllerTest < API::BaseTestCase
    #########
    # INDEX #
    #########
    test "index should proxy params" do
      track = create :track
      exercise = create(:concept_exercise, track:)

      Solution::SearchViaRepresentations.expects(:call).with(
        exercise,
        page: '5',
        order: "newest",
        criteria: "author",
        tags: nil
      ).returns(Solution.page(1))

      get api_track_exercise_community_solutions_path(
        track, exercise,
        page: 5,
        order: "newest",
        criteria: "author"
      ), headers: @headers, as: :json

      assert_response :ok
    end

    test "index should search and return solutions" do
      track = create :track
      exercise = create(:concept_exercise, :random_slug, track:)
      exercise_representation_1 = create(:exercise_representation, exercise:)
      exercise_representation_2 = create(:exercise_representation, exercise:)
      solution_1 = create :concept_solution, exercise:, published_at: Time.current, num_stars: 11,
        published_iteration_head_tests_status: :passed,
        published_exercise_representation: exercise_representation_1
      submission_1 = create :submission, solution: solution_1, tests_status: :passed
      create :submission_representation, submission: submission_1, ast: exercise_representation_1.ast
      create :iteration, solution: solution_1, submission: submission_1
      solution_2 = create :concept_solution, exercise:, published_at: Time.current, num_stars: 22,
        published_iteration_head_tests_status: :passed,
        published_exercise_representation: exercise_representation_2
      submission_2 = create :submission, solution: solution_2, tests_status: :passed
      create :submission_representation, submission: submission_2, ast: exercise_representation_1.ast
      create :iteration, solution: solution_2, submission: submission_2
      create :concept_solution, published_at: Time.current, num_stars: 33

      exercise.update(num_published_solutions: 2)
      perform_enqueued_jobs do
        Exercise::Representation::Recache.(exercise_representation_1)
        Exercise::Representation::Recache.(exercise_representation_2)
      end

      wait_for_opensearch_to_be_synced

      get api_track_exercise_community_solutions_path(
        track, exercise
      ), headers: @headers, as: :json

      assert_response :ok
      expected = SerializePaginatedCollection.(
        exercise.solutions.order(id: :asc).page(1),
        serializer: SerializeCommunitySolutions,
        meta: {
          unscoped_total: 2
        }
      ).to_json
      assert_equal expected, response.body
    end
  end
end
