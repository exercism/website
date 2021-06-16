require "test_helper"

class ContributorTeam::CreateTest < ActiveSupport::TestCase
  test "creates contributor team" do
    track = create :track

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

  test "idempotent" do
    track = create :track

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
