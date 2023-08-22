require "test_helper"

class User::DismissedIntroducerTest < ActiveSupport::TestCase
  test "creates correctly" do
    user = create :user
    introducer = create(:user_dismissed_introducer, user:)

    assert_equal user, introducer.user
    assert_equal [introducer], user.dismissed_introducers
  end
end
