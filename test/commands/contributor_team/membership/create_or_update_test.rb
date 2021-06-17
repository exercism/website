require "test_helper"

class ContributorTeam::Membership::CreateOrUpdateTest < ActiveSupport::TestCase
  test "creates contributor team membership" do
    user = create :user
    team = create :contributor_team

    ContributorTeam::Membership::CreateOrUpdate.(
      user,
      team,
      seniority: :junior,
      visible: true
    )

    assert_equal 1, ContributorTeam::Membership.count
    m = ContributorTeam::Membership.last

    assert_equal user, m.user
    assert_equal team, m.team
    assert_equal :junior, m.seniority
    assert m.visible
  end

  test "updates contributor team membership" do
    user = create :user
    team = create :contributor_team
    membership = create :contributor_team_membership, user: user, team: team, seniority: :senior, visible: false

    # Sanity check
    assert_equal user, membership.user
    assert_equal team, membership.team
    assert_equal :senior, membership.seniority
    refute membership.visible

    ContributorTeam::Membership::CreateOrUpdate.(
      user,
      team,
      seniority: :junior,
      visible: true
    )

    membership.reload
    assert_equal user, membership.user
    assert_equal team, membership.team
    assert_equal :junior, membership.seniority
    assert membership.visible
  end

  test "idempotent" do
    user = create :user
    team = create :contributor_team, type: :track_maintainers

    assert_idempotent_command do
      ContributorTeam::Membership::CreateOrUpdate.(
        user,
        team,
        seniority: :junior,
        visible: true
      )
    end
  end
end
