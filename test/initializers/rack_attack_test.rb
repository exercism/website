require './test/controllers/webhooks/base_test_case'

class RackAttackTest < Webhooks::BaseTestCase
  test "rate limit authorized API POST/PATCH/PUT/DELETE requests by token/route/action" do
    freeze_time do
      user_1 = create :user, reputation: 5
      user_2 = create :user, reputation: 5

      setup_user(user_2)

      # Sanity check: different token does not count against rate limit
      5.times do
        put api_user_path, params: { user: User.find(@current_user.id) }, headers: @headers, as: :json
        assert_response :success
      end

      logout
      setup_user(user_1)

      # Sanity check: different path does not count against limit
      5.times do
        post api_parse_markdown_path, params: { markdown: "*Hello*" }, headers: @headers, as: :json
        assert_response :success
      end

      # Sanity check: different HTTP method does not count against limit
      5.times do
        patch api_user_path, params: { user: User.find(@current_user.id) }, headers: @headers, as: :json
        assert_response :success
      end

      # Sanity check: response not rate limited while not exceeding limit
      5.times do
        put api_user_path, params: { user: User.find(@current_user.id) }, headers: @headers, as: :json
        assert_response :success
      end

      # Exceeding rate limit returns too_many_requests response
      put api_user_path, params: { user: User.find(@current_user.id) }, headers: @headers, as: :json
      assert_response :too_many_requests
    end
  end

  test "rate limit uses route, not path for throttling" do
    freeze_time do
      user = create :user
      track = create :track
      create(:user_track, track:, user:)

      setup_user(user)

      # Call the same route with different parameters,
      # which leads to a different URL path
      5.times do
        solution = create(:practice_solution, user:, track:)
        create(:iteration, solution:)

        patch complete_api_solution_path(solution.uuid), headers: @headers, as: :json

        assert_response :success
      end

      # Exceeding rate limit returns too_many_requests response
      solution = create(:practice_solution, user:, track:)
      create(:iteration, solution:)

      patch complete_api_solution_path(solution.uuid), headers: @headers, as: :json

      assert_response :too_many_requests
    end
  end

  test "don't rate limit authorized API GET requests" do
    setup_user

    50.times do
      get api_tracks_path, headers: @headers
      assert_response :ok
    end
  end

  test "don't rate limit unauthorized API GET requests" do
    logout

    50.times do
      get api_tracks_path
      assert_response :ok
    end
  end

  test "don't rate limit unauthorized non-API GET requests" do
    logout

    50.times do
      get tracks_path
      assert_response :ok
    end
  end

  test "don't rate limit unauthorized non-API POST/PATCH/PUT/DELETE requests" do
    logout

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

  test "rate limit resets each minute" do
    user = create :user, reputation: 5

    setup_user(user)

    beginning_of_minute = Time.current.beginning_of_minute

    # First five requests are successful as they don't exceed the throttling limit
    [1, 5, 13, 22, 28].each do |seconds_passed|
      travel_to beginning_of_minute + seconds_passed.seconds do
        put api_user_path, params: { user: @current_user }, headers: @headers, as: :json
        assert_response :success
      end
    end

    # Hit rate limit for requests within the same minute that exceed the throttling limit
    [33, 44, 59].each do |seconds_passed|
      travel_to beginning_of_minute + seconds_passed.seconds do
        put api_user_path, params: { user: @current_user }, headers: @headers, as: :json
        assert_response :too_many_requests
      end
    end

    # Rate limit resets at 1 minute
    travel_to beginning_of_minute + 1.minute do
      5.times do
        put api_user_path, params: { user: @current_user }, headers: @headers, as: :json
        assert_response :success
      end
    end
  end

  test "retry-after header is returned when rate limit is reached" do
    travel_to Time.current.beginning_of_minute + 18.seconds do
      setup_user

      6.times do
        put api_user_path, params: { user: @current_user }, headers: @headers, as: :json
      end

      assert_response :too_many_requests
      assert_includes response.get_header("Retry-After"), "42" # 42 is number of secs remaining this minute
    end
  end

  test "sidekiq is not blocked" do
    user = create :user, :admin
    setup_user(user)

    50.times do
      get sidekiq_web_path
      assert_response :redirect
    end
  end

  def setup_user(user = nil)
    @current_user = user || create(:user)
    @current_user.confirm

    auth_token = create :user_auth_token, user: @current_user
    @headers = { 'Authorization' => "Token token=#{auth_token.token}" }
  end
end
