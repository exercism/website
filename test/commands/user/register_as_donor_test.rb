require "test_helper"

class User::RegisterAsDonorTest < ActiveSupport::TestCase
  test "updates first_donated_at when not set" do
    user = create :user, first_donated_at: nil
    first_donated_at = Time.utc(2021, 7, 22)

    User::RegisterAsDonor.(user, first_donated_at)

    assert_equal first_donated_at, user.first_donated_at
    assert user.donated?
  end

  test "does not update first_donated_at when already set" do
    first_donated_at = Time.utc(2021, 7, 22)
    user = create(:user, first_donated_at:)

    User::RegisterAsDonor.(user, Time.current)

    assert_equal first_donated_at, user.first_donated_at
    assert user.donated?
  end

  test "awards supporter badge" do
    user = create :user, first_donated_at: nil
    refute user.badges.present?

    perform_enqueued_jobs do
      User::RegisterAsDonor.(user, Time.current)
    end

    assert_includes user.reload.badges, Badges::SupporterBadge.first
  end
end
