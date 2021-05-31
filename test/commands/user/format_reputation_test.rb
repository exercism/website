require 'test_helper'

class User::FormatReputationTest < ActiveSupport::TestCase
  test "works correctly" do
    assert_equal "0", create(:user, reputation: 0).formatted_reputation
    assert_equal "10", create(:user, reputation: 10).formatted_reputation
    assert_equal "100", create(:user, reputation: 100).formatted_reputation
    assert_equal "1,234", create(:user, reputation: 1234).formatted_reputation
    assert_equal "9,999", create(:user, reputation: 9999).formatted_reputation
    assert_equal "12.3k", create(:user, reputation: 12_345).formatted_reputation
    assert_equal "99.9k", create(:user, reputation: 99_999).formatted_reputation
    assert_equal "123k", create(:user, reputation: 123_456).formatted_reputation
  end
end
