require "test_helper"

class User::BootstrapTest < ActiveSupport::TestCase
  test "creates auth_token" do
    user = create :user
    refute user.auth_tokens.present?

    User::Bootstrap.(user)
    assert user.auth_tokens.present?
  end

  test "awards member badge" do
    user = create :user
    refute user.badges.present?

    User::Bootstrap.(user)
    perform_enqueued_jobs
    assert_equal Badges::MemberBadge, user.reload.badges.first.class
  end
end
