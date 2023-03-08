require "test_helper"

class User::RegisterAsDonorTest < ActiveSupport::TestCase
  test "updates donated?" do
    user = create :user, donated: false

    User::RegisterAsDonor.(user)

    assert user.donated?
  end

  test "awards supporter badge" do
    user = create :user, donated: false
    refute user.badges.present?

    perform_enqueued_jobs do
      User::RegisterAsDonor.(user)
    end

    assert_includes user.reload.badges, Badges::SupporterBadge.first
  end
end
