require 'test_helper'

module API
  class BaseTestCase < ActionDispatch::IntegrationTest
    def self.guard_incorrect_token!(path, args: 0, method: :get)
      test "index should return 401 with incorrect token for #{method} #{path}" do
        url = send(path, *Array.new(args, 'a')) # rubocop:disable Lint/RedundantSplatExpansion
        send(method, url, as: :json)

        assert_response :unauthorized
        expected = { error: {
          type: "invalid_auth_token",
          message: I18n.t('api.errors.invalid_auth_token')
        } }
        actual = JSON.parse(response.body, symbolize_names: true)
        assert_equal expected, actual
      end
    end

    def setup_user(user = nil)
      @current_user = user || create(:user)
      @current_user.confirm

      auth_token = create :user_auth_token, user: @current_user
      @headers = { 'Authorization' => "Token token=#{auth_token.token}" }
    end
  end
end
