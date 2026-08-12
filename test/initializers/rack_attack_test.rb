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

  test "routed_to returns nil rather than raising when the route cannot be resolved" do
    # recognize_path raises RoutingError for unknown paths, but it can also
    # raise other things - NoMethodError for paths mounted outside the router,
    # or anything at all from a route constraint. None of them should escape
    # into the middleware stack and 500 the request.
    [ActionController::RoutingError, NoMethodError, RuntimeError].each do |error_class|
      Rails.application.routes.stubs(:recognize_path).raises(error_class, "boom")

      request = Rack::Attack::Request.new(Rack::MockRequest.env_for("/anything"))
      assert_nil request.routed_to
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

  test "unauthenticated exercise page requests under the limit are not throttled" do
    create :practice_exercise
    ip = "1.2.3.4"

    freeze_time do
      fill_crawl_throttle(ip, 499)

      get "/tracks/ruby/exercises/bob", headers: crawler_headers(ip)
      assert_response :ok
    end
  end

  test "unauthenticated exercise page requests over the limit are throttled" do
    create :practice_exercise
    ip = "1.2.3.5"

    freeze_time do
      fill_crawl_throttle(ip, 500)

      get "/tracks/ruby/exercises/bob", headers: crawler_headers(ip)
      assert_response :too_many_requests
    end
  end

  test "unauthenticated submission files requests over the limit are throttled" do
    solution = create :practice_solution
    submission = create(:submission, solution:)
    ip = "1.2.3.6"

    freeze_time do
      fill_crawl_throttle(ip, 500)

      get api_solution_submission_files_path(solution.uuid, submission.uuid), headers: crawler_headers(ip)
      assert_response :too_many_requests
    end
  end

  test "authenticated requests are not throttled by the crawl throttle" do
    create :practice_exercise
    ip = "1.2.3.7"

    freeze_time do
      fill_crawl_throttle(ip, 500)

      get "/tracks/ruby/exercises/bob", headers: crawler_headers(ip).merge('HTTP_COOKIE' => '_exercism_user_id=123')
      assert_response :ok
    end
  end

  test "verified search engines are safelisted from the crawl throttle" do
    create :practice_exercise
    ip = "1.2.3.8"

    freeze_time do
      fill_crawl_throttle(ip, 500)

      get "/tracks/ruby/exercises/bob", headers: crawler_headers(ip).merge('HTTP_X_SEARCH_ENGINE' => 'true')
      assert_response :ok
    end
  end

  test "unverified search engine header does not bypass the crawl throttle" do
    create :practice_exercise
    ip = "1.2.3.9"

    freeze_time do
      fill_crawl_throttle(ip, 500)

      get "/tracks/ruby/exercises/bob", headers: crawler_headers(ip).merge('HTTP_X_SEARCH_ENGINE' => 'false')
      assert_response :too_many_requests
    end
  end

  test "other paths are unaffected by the crawl throttle" do
    create :track
    ip = "1.2.3.10"

    freeze_time do
      fill_crawl_throttle(ip, 500)

      get tracks_path, headers: crawler_headers(ip)
      assert_response :ok
    end
  end

  test "the crawl throttle is keyed on CF-Connecting-IP, not the connecting address" do
    create :practice_exercise

    freeze_time do
      fill_crawl_throttle("1.2.3.11", 500)

      # A different real client behind the same Cloudflare PoP is unaffected
      get "/tracks/ruby/exercises/bob", headers: crawler_headers("1.2.3.12")
      assert_response :ok
    end
  end

  def crawler_headers(ip)
    { 'HTTP_CF_CONNECTING_IP' => ip }
  end

  def fill_crawl_throttle(ip, count)
    key = "Unauthenticated crawling of expensive endpoints:unauthenticated-crawl|#{ip}"
    count.times { Rack::Attack.cache.count(key, 1.day) }
  end

  def setup_user(user = nil)
    @current_user = user || create(:user)
    @current_user.confirm

    auth_token = create :user_auth_token, user: @current_user
    @headers = { 'Authorization' => "Bearer #{auth_token.token}" }
  end
end
