require "test_helper"

class ContributorTeam::AddTrackMaintainerTest < ActiveSupport::TestCase
  test "add user to track maintainers team" do
    user = create :user
    track = create :track
    team = create :contributor_team, track: track, type: :track_maintainers

    Github::Team::AddMember.stubs(:call)
    Github::Team::AddToRepository.stubs(:call)
    Github::Team::FetchMembers.stubs(:call).returns([])

    # Create other track team to ensure the right team is chosen
    csharp_track = create :track, slug: 'csharp'
    create :contributor_team, :random, track: csharp_track, type: :track_maintainers
    create :contributor_team, :random, track: nil, type: :reviewers

    ContributorTeam::AddTrackMaintainer.(user, track, visible: true, seniority: :junior)

    assert_includes team.members, user
  end

  test "adds maintainer role" do
    user = create :user
    track = create :track
    create :contributor_team, track: track, type: :track_maintainers

    Github::Team::AddMember.stubs(:call)
    Github::Team::AddToRepository.stubs(:call)
    Github::Team::FetchMembers.stubs(:call).returns([])

    ContributorTeam::AddTrackMaintainer.(user, track, visible: true, seniority: :junior)

    assert_includes user.roles, :maintainer
  end

  test "does not add duplicate maintainer role" do
    user = create :user, roles: [:maintainer]
    track = create :track
    create :contributor_team, track: track, type: :track_maintainers

    Github::Team::AddMember.stubs(:call)
    Github::Team::AddToRepository.stubs(:call)
    Github::Team::FetchMembers.stubs(:call).returns([])

    ContributorTeam::AddTrackMaintainer.(user, track, visible: true, seniority: :junior)

    assert_equal 1, (user.roles.count { |r| r == :maintainer })
  end

  test "keeps existing roles" do
    user = create :user, roles: %i[admin reviewer]
    track = create :track
    create :contributor_team, track: track, type: :track_maintainers

    Github::Team::AddMember.stubs(:call)
    Github::Team::AddToRepository.stubs(:call)
    Github::Team::FetchMembers.stubs(:call).returns([])

    ContributorTeam::AddTrackMaintainer.(user, track, visible: true, seniority: :junior)

    assert_equal 3, user.roles.size
    assert_includes user.roles, :admin
    assert_includes user.roles, :reviewer
    assert_includes user.roles, :maintainer
  end

  test "raises exception when team could not be found" do
    track = create :track
    user = create :user

    assert_raises do
      ContributorTeam::AddTrackMaintainer.(user, track)
    end
  end
end
