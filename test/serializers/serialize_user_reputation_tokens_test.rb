require 'test_helper'

class SerializeUserReputationTokensTest < ActiveSupport::TestCase
  test "basic test" do
    token = create :user_code_contribution_reputation_token

    expected = [
      SerializeUserReputationToken.(token)
    ]

    assert_equal expected, SerializeUserReputationTokens.(
      [token]
    )
  end
end
