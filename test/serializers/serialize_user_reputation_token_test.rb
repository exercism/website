require 'test_helper'

class SerializeUserReputationTokenTest < ActiveSupport::TestCase
  test "basic test" do
    token = create :user_code_contribution_reputation_token

    assert_equal token.rendering_data, SerializeUserReputationToken.(token)
  end
end
