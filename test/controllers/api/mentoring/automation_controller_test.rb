require_relative '../base_test_case'

class API::Mentoring::AutomationControllerTest < API::BaseTestCase
  include Propshaft::Helper

  guard_incorrect_token! :with_feedback_api_mentoring_automation_path
  guard_incorrect_token! :without_feedback_api_mentoring_automation_path

  ###
  # without_feedback
  ###
  test "without_feedback retrieves representations" do
    track = create :track
    user = create :user
    create :user_track_mentorship, user: user, track: track
    exercise = create :practice_exercise, track: track
    setup_user(user)

    representations = Array.new(25) do |idx|
      create :exercise_representation, num_submissions: idx, feedback_type: nil, exercise: exercise
    end

    get without_feedback_api_mentoring_automation_path, headers: @headers, as: :json
    assert_response :ok

    paginated_representations = Kaminari.paginate_array(representations, total_count: 25).page(1).per(20)
    expected = SerializePaginatedCollection.(
      paginated_representations,
      serializer: SerializeExerciseRepresentations,
      meta: {
        unscoped_total: 25
      }
    )
    assert_equal JSON.parse(expected.to_json), JSON.parse(response.body)
  end

  ###
  # with_feedback
  ###
  test "with_feedback retrieves representations" do
    user = create :user
    setup_user(user)

    representations = Array.new(25) do |idx|
      create :exercise_representation, num_submissions: idx, feedback_type: :actionable, feedback_author: user
    end

    get with_feedback_api_mentoring_automation_path, headers: @headers, as: :json
    assert_response :ok

    paginated_representations = Kaminari.paginate_array(representations, total_count: 25).page(1).per(20)
    expected = SerializePaginatedCollection.(
      paginated_representations,
      serializer: SerializeExerciseRepresentations,
      meta: {
        unscoped_total: 25
      }
    )
    assert_equal JSON.parse(expected.to_json), JSON.parse(response.body)
  end
end
