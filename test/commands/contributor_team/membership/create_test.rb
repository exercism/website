require "test_helper"

class ContributorTeam::Membership::CreateTest < ActiveSupport::TestCase
  test "creates concept" do
    user = create :user
    team = create :contributor_team

    ContributorTeam::Membership::Create.(
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

  test "idempotent" do
    user = create :user
    team = create :contributor_team

    assert_idempotent_command do
      ContributorTeam::Membership::Create.(
        user,
        team,
        seniority: :junior,
        visible: true
      )
    end
  end
end
