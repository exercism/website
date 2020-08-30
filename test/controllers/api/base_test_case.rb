require 'test_helper'

module API
  class BaseTestCase < ActionDispatch::IntegrationTest
    def setup_user
      @current_user = create :user

      # TODO: - Reenable once Devise is added
      # @current_user.confirm

      auth_token = create :user_auth_token, user: @current_user
      @headers = { 'Authorization' => "Token token=#{auth_token.token}" }
    end
  end
end
