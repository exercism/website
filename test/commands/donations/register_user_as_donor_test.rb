require "test_helper"

class Donations::RegisterUserAsDonorTest < ActiveSupport::TestCase
  test "updates first_donated_at" do
    user = create :user, first_donated_at: nil
    first_donated_at = Time.utc(2021, 7, 22)

    Donations::RegisterUserAsDonor.(user, first_donated_at)

    assert_equal first_donated_at, user.first_donated_at
    assert user.donated?
  end

  test "awards supporter badge" do
    user = create :user, first_donated_at: nil
    refute user.badges.present?

    perform_enqueued_jobs do
      Donations::RegisterUserAsDonor.(user, Time.current)
    end

    assert_includes user.reload.badges, Badges::SupporterBadge.first
  end
end
