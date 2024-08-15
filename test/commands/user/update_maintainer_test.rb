require "test_helper"

class User::UpdateMaintainerTest < ActiveSupport::TestCase
  test "does not become maintainer when not member of track github team" do
    user = create :user

    # Sanity check
    refute user.maintainer?

    User::UpdateMaintainer.(user)

    refute user.maintainer?
  end

  test "becomes maintainer when member of track github team" do
    user = create(:user, uid: SecureRandom.uuid)
    track = create :track
    create(:github_team_member, user:, team_name: track.slug)

    # Sanity check
    refute user.maintainer?

    User::UpdateMaintainer.(user)

    assert user.maintainer?
  end

  test "loses maintainership when no longer member of track github team" do
    user = create :user, :maintainer

    # Sanity check
    assert user.maintainer?

    User::UpdateMaintainer.(user)

    refute user.maintainer?
  end

  test "retains maintainership when still member of track github team" do
    user = create(:user, :maintainer, uid: SecureRandom.uuid)
    track = create :track
    create(:github_team_member, user:, team_name: track.slug)

    # Sanity check
    assert user.maintainer?

    User::UpdateMaintainer.(user)

    assert user.maintainer?
  end

  test "admins are always maintainers" do
    user = create(:user, :admin)

    # Sanity check
    assert user.maintainer?

    User::UpdateMaintainer.(user)

    assert user.maintainer?
  end
end
