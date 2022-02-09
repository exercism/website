require_relative './base_test_case'

module API
  class BaseControllerTest < API::BaseTestCase
    test "log usage for authenticated request" do
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

      assert_equal "3", redis.get("test:api_request:foo:2022-01-05 14:53")
      assert_equal "1", redis.get("test:api_request:bar:2022-01-05 14:53")

      travel_to(Time.utc(2022, 1, 5, 15, 11, 55))
      get api_docs_path, headers: @headers, as: :json
      get api_docs_path, headers: @headers, as: :json

      sleep(0.1)

      assert_nil redis.get("test:api_request:foo:2022-01-05 15:11")
      assert_equal "2", redis.get("test:api_request:bar:2022-01-05 15:11")
    end

    test "does not log usage for anonymous request" do
      travel_to(Time.zone.local(2022, 1, 5, 14, 53, 7))
      redis = Exercism.redis_tooling_client

      get api_docs_path, headers: @headers, as: :json
      sleep(0.1)

      keys = redis.keys("#{Exercism.env}:api_request:*")
      assert_empty keys
    end
  end
end
