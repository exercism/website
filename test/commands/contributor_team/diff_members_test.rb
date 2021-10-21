require "test_helper"

class ContributorTeam::DiffMembersTest < ActiveSupport::TestCase
  test "diff members" do
    Github::Organization.any_instance.stubs(:name).returns('exercism')

    team = create :contributor_team, github_name: 'csharp'
    create :contributor_team_membership, team: team, user: (create :user, github_username: 'user1')
    create :contributor_team_membership, team: team, user: (create :user, github_username: 'user2')

    stub_request(:get, "https://api.github.com/orgs/exercism/teams/csharp").
      to_return(status: 200, body: { id: 555 }.to_json, headers: { 'Content-Type': 'application/json' })

    stub_request(:get, "https://api.github.com/teams/555/members?per_page=100").
      to_return(status: 200, body: [{ login: 'user1' }, { login: 'user3' }].to_json, headers: { 'Content-Type': 'application/json' })

    diff = ContributorTeam::DiffMembers.(team)
    assert_equal ['user1'], diff[:in_both].to_a
    assert_equal ['user2'], diff[:only_in_db].to_a
    assert_equal ['user3'], diff[:only_on_github].to_a
  end
end
