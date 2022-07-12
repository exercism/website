require './test/controllers/webhooks/base_test_case'

class RackAttackTest < Webhooks::BaseTestCase
  test "rate limit authorized API POST/PATCH/PUT/DELETE requests by token" do
    user_1 = create :user
    user_2 = create :user

    setup_user(user_2)

    # Sanity check: rate limit of other user doesn't interfere
    7.times do
      submission = create :submission, user: @current_user
      post api_solution_iterations_path(submission.solution.uuid, submission_uuid: submission.uuid), headers: @headers
    end

    assert_response :too_many_requests

    logout
    setup_user(user_1)

    # First four times for user won't hit rate limit
    4.times do
      submission = create :submission, user: @current_user
      post api_solution_iterations_path(submission.solution.uuid, submission_uuid: submission.uuid), headers: @headers
      assert_response :success
    end

    # Fifth request for user in one minute hits rate limit
    submission = create :submission, user: @current_user
    post api_solution_iterations_path(submission.solution.uuid, submission_uuid: submission.uuid), headers: @headers
    assert_response :too_many_requests

    # Verify that the rate limit for a user resets every minute
    travel_to Time.current + 1.minute

    submission = create :submission, user: @current_user
    post api_solution_iterations_path(submission.solution.uuid, submission_uuid: submission.uuid), headers: @headers
    assert_response :success
  end

  test "don't rate limit authorized API GET requests" do
    setup_user

    50.times do
      get api_tracks_path, headers: @headers
      assert_response :success
    end
  end

  test "don't rate limit unauthorized API GET requests" do
    logout

    50.times do
      get api_tracks_path
      assert_response :success
    end
  end

  test "don't rate limit unauthorized non-API GET requests" do
    logout

    50.times do
      get tracks_path
      assert_response :success
    end
  end

  test "don't rate limit unauthorized non-API POST/PATCH/PUT/DELETE requests" do
    logout

    create :user, github_username: 'member12'
    create :contributor_team, github_name: 'reviewers'

    payload = {
      action: 'added',
      member: {
        login: 'member12'
      },
      team: {
        name: 'reviewers'
      },
      organization: {
        login: 'exercism'
      }
    }

    50.times do
      post webhooks_membership_updates_path, headers: headers(payload), as: :json, params: payload
      assert_response :success
    end
  end

  test "retry-after header is returned when rate limit is reached" do
    travel_to Time.current.beginning_of_minute + 18.seconds do
      setup_user

      5.times do
        submission = create :submission, user: @current_user
        post api_solution_iterations_path(submission.solution.uuid, submission_uuid: submission.uuid), headers: @headers
      end

      assert_response :too_many_requests
      assert_includes response.get_header("Retry-After"), "42" # 42 is number of secs remaining this minute
    end
  end

  def setup_user(user = nil)
    @current_user = user || create(:user)
    @current_user.confirm

    auth_token = create :user_auth_token, user: @current_user
    @headers = { 'Authorization' => "Token token=#{auth_token.token}" }
  end
end
