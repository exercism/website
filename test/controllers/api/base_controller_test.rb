require_relative './base_test_case'

module API
  class BaseControllerTest < API::BaseTestCase
    test "log user for authenticated API request" do
      travel_to(Time.utc(2022, 1, 5, 14, 53, 7))
      redis = Exercism.redis_tooling_client
      user_1 = create :user, handle: 'foo'
      user_2 = create :user, handle: 'bar'

      setup_user(user_1)
      get api_docs_path, headers: @headers, as: :json
      get api_docs_path, headers: @headers, as: :json
      get api_docs_path, headers: @headers, as: :json
      sign_out user_1

      setup_user(user_2)
      get api_docs_path, headers: @headers, as: :json

      sleep(0.1)

      assert_equal "3", redis.get("test:request:user:foo:2022-01-05 14:53")
      assert_equal "1", redis.get("test:request:user:bar:2022-01-05 14:53")

      travel_to(Time.utc(2022, 1, 5, 15, 11, 55))
      get api_docs_path, headers: @headers, as: :json
      get api_docs_path, headers: @headers, as: :json

      sleep(0.1)

      assert_nil redis.get("test:request:user:foo:2022-01-05 15:11")
      assert_equal "2", redis.get("test:request:user:bar:2022-01-05 15:11")
    end

    test "log url and HTTP method for API request" do
      travel_to(Time.utc(2022, 1, 5, 14, 53, 7))
      redis = Exercism.redis_tooling_client
      setup_user

      get api_docs_path, headers: @headers, as: :json
      get api_docs_path, headers: @headers, as: :json
      get api_docs_path, headers: @headers, as: :json

      get api_ping_path, headers: @headers, as: :json

      sleep(0.1)

      assert_equal "3", redis.get("test:request:url:/api/v2/docs:GET:2022-01-05 14:53")
      assert_equal "1", redis.get("test:request:url:/api/v2/ping:GET:2022-01-05 14:53")

      travel_to(Time.utc(2022, 1, 5, 15, 11, 55))
      get api_ping_path, headers: @headers, as: :json
      get api_ping_path, headers: @headers, as: :json
      post api_parse_markdown_path, headers: @headers, as: :json, params: { markdown: "*Hello*" }

      sleep(0.1)

      assert_nil redis.get("test:request:url:/api/v2/docs:GET:2022-01-05 15:11")
      assert_equal "2", redis.get("test:request:url:/api/v2/ping:GET:2022-01-05 15:11")
      assert_equal "1", redis.get("test:request:url:/api/v2/markdown/parse:POST:2022-01-05 15:11")
    end

    test "does not log user for anonymous API request" do
      travel_to(Time.zone.local(2022, 1, 5, 14, 53, 7))
      redis = Exercism.redis_tooling_client

      get api_docs_path, headers: @headers, as: :json
      sleep(0.1)

      keys = redis.keys("#{Exercism.env}:request:user:*")
      assert_empty keys
    end

    test "does not log requests for non-API request" do
      travel_to(Time.zone.local(2022, 1, 5, 14, 53, 7))
      redis = Exercism.redis_tooling_client

      get tracks_path, headers: @headers
      sleep(0.1)

      keys = redis.keys("#{Exercism.env}:request:*")
      assert_empty keys
    end
  end
end
