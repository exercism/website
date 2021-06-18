require "test_helper"

class ContributorTeam::CreateTest < ActiveSupport::TestCase
  test "creates contributor team" do
    track = create :track

    Github::Team::Create.stubs(:call)

    ContributorTeam::Create.(
      'C# maintainers',
      github_name: 'csharp-maintainers',
      type: :track_maintainers,
      track: track
    )

    assert_equal 1, ContributorTeam.count
    c = ContributorTeam.last

    assert_equal 'C# maintainers', c.name
    assert_equal track, c.track
    assert_equal :track_maintainers, c.type
  end

  test "creates github team if team does not exist" do
    track = create :track, slug: 'csharp'

    Github::Team::Create.expects(:call).with("csharp", "exercism/csharp")

    ContributorTeam::Create.(
      'C# maintainers',
      github_name: 'csharp',
      type: :track_maintainers,
      track: track
    )
  end

  test "does not create github team if team already exists" do
    Github::Team::Create.expects(:call).never

    track = create :track, slug: 'csharp'
    team = create :contributor_team, name: 'C# maintainers', github_name: 'csharp', track: track, type: :track_maintainers

    ContributorTeam::Create.(
      team.name,
      github_name: team.github_name,
      type: team.type,
      track: team.track
    )
  end

  test "idempotent" do
    track = create :track

    Github::Team::Create.stubs(:call)

    assert_idempotent_command do
      ContributorTeam::Create.(
        'C# maintainers',
        github_name: 'csharp-maintainers',
        type: :track_maintainers,
        track: track
      )
    end
  end
end
