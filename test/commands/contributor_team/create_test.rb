require "test_helper"

class ContributorTeam::CreateTest < ActiveSupport::TestCase
  test "create track maintainers team" do
    track = create :track

    ContributorTeam::Create.('csharp', type: :track_maintainers, track:)

    assert_equal 1, ContributorTeam.count
    c = ContributorTeam.last

    assert_equal 'csharp', c.github_name
    assert_equal :track_maintainers, c.type
    assert_equal track, c.track
  end

  test "create project maintainers team" do
    ContributorTeam::Create.('configlet', type: :project_maintainers)

    assert_equal 1, ContributorTeam.count
    c = ContributorTeam.last

    assert_equal 'configlet', c.github_name
    assert_equal :project_maintainers, c.type
    assert_nil c.track
  end

  test "create reviewers team" do
    ContributorTeam::Create.('reviewers', type: :reviewers)

    assert_equal 1, ContributorTeam.count
    c = ContributorTeam.last

    assert_equal 'reviewers', c.github_name
    assert_equal :reviewers, c.type
    assert_nil c.track
  end

  test "idempotent" do
    track = create :track

    assert_idempotent_command do
      ContributorTeam::Create.('csharp', type: :track_maintainers, track:)
    end
  end
end
