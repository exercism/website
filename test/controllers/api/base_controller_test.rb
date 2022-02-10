require_relative './base_test_case'

module API
  class BaseControllerTest < API::BaseTestCase
    test "logs authenticated request count" do
      travel_to(Time.utc(2022, 1, 5, 14, 53, 7))
      user = create :user, id: 1
      setup_user(user)

      get api_docs_path, headers: @headers, as: :json
      get api_docs_path, headers: @headers, as: :json
      post api_parse_markdown_path, headers: @headers, as: :json, params: { markdown: "*Hello*" }

      sleep(0.1)
      redis = Redis.new(url: "#{Exercism.config.tooling_redis_url}/5")
      assert_equal "2", redis.get("test:request:/api/v2/docs:GET:1:2022-01-05 14:53")
      assert_equal "1", redis.get("test:request:/api/v2/markdown/parse:POST:1:2022-01-05 14:53")
    end

    test "logs authenticated request per minute" do
      user = create :user, id: 1
      setup_user(user)

      travel_to(Time.utc(2022, 1, 5, 14, 53, 7))
      get api_docs_path, headers: @headers, as: :json

      travel_to(Time.utc(2022, 1, 5, 15, 11, 55))
      get api_docs_path, headers: @headers, as: :json
      get api_docs_path, headers: @headers, as: :json

      sleep(0.1)
      redis = Redis.new(url: "#{Exercism.config.tooling_redis_url}/5")
      assert_equal "1", redis.get("test:request:/api/v2/docs:GET:1:2022-01-05 14:53")
      assert_equal "2", redis.get("test:request:/api/v2/docs:GET:1:2022-01-05 15:11")
    end

    test "logs authenticated request per user" do
      travel_to(Time.utc(2022, 1, 5, 14, 53, 7))
      user_1 = create :user, id: 1
      user_2 = create :user, id: 2

      setup_user(user_1)
      get api_docs_path, headers: @headers, as: :json
      get api_docs_path, headers: @headers, as: :json
      sign_out user_1
      setup_user(user_2)
      get api_docs_path, headers: @headers, as: :json

      sleep(0.1)
      redis = Redis.new(url: "#{Exercism.config.tooling_redis_url}/5")
      assert_equal "2", redis.get("test:request:/api/v2/docs:GET:1:2022-01-05 14:53")
      assert_equal "1", redis.get("test:request:/api/v2/docs:GET:2:2022-01-05 14:53")
    end

    test "logs request path without query parameters" do
      travel_to(Time.utc(2022, 1, 5, 14, 53, 7))
      user = create :user, id: 1
      setup_user(user)

      get api_notifications_path, headers: @headers, as: :json
      get api_notifications_path(page: 2), headers: @headers, as: :json
      get api_notifications_path(page: 2, order: :unread_first), headers: @headers, as: :json

      sleep(0.1)
      redis = Redis.new(url: "#{Exercism.config.tooling_redis_url}/5")
      assert_equal "3", redis.get("test:request:/api/v2/notifications:GET:1:2022-01-05 14:53")
    end

    test "does not log anonymous requests" do
      get api_docs_path, headers: @headers, as: :json

      sleep(0.1)
      redis = Redis.new(url: "#{Exercism.config.tooling_redis_url}/5")
      assert_empty redis.keys("test:request:*")
    end

    test "does not log non-API requests" do
      setup_user
      get tracks_path, headers: @headers

      sleep(0.1)
      redis = Redis.new(url: "#{Exercism.config.tooling_redis_url}/5")
      assert_empty redis.keys("test:request:*")
    end
  end
end
