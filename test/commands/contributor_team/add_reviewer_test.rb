require "test_helper"

class ContributorTeam::AddReviewerTest < ActiveSupport::TestCase
  test "add user to reviewers team" do
    user = create :user
    team = create :contributor_team, track: nil, type: :reviewers

    Github::Team::AddMember.expects(:call).with(team.github_name, user.github_username)

    # Create other reviewer team to ensure the right team is chosen
    create :contributor_team, :random, track: nil, type: :reviewers

    ContributorTeam::AddReviewer.(user, visible: true, seniority: :junior)

    assert_includes team.members, user
  end

  test "adds reviewer role" do
    user = create :user
    team = create :contributor_team, track: nil, type: :reviewers

    Github::Team::AddMember.expects(:call).with(team.github_name, user.github_username)

    ContributorTeam::AddReviewer.(user, visible: true, seniority: :junior)

    assert_includes user.roles, :reviewer
  end

  test "does not add duplicate reviewer role" do
    user = create :user, roles: [:reviewer]
    team = create :contributor_team, track: nil, type: :reviewers

    Github::Team::AddMember.expects(:call).with(team.github_name, user.github_username)

    ContributorTeam::AddReviewer.(user, visible: true, seniority: :junior)

    assert_equal 1, (user.roles.count { |r| r == :reviewer })
  end

  test "keeps existing roles" do
    user = create :user, roles: %i[admin track_maintainer]
    team = create :contributor_team, track: nil, type: :reviewers

    Github::Team::AddMember.expects(:call).with(team.github_name, user.github_username)

    ContributorTeam::AddReviewer.(user, visible: true, seniority: :junior)

    assert_equal 3, user.roles.size
    assert_includes user.roles, :admin
    assert_includes user.roles, :reviewer
    assert_includes user.roles, :track_maintainer
  end

  test "raises exception when team could not be found" do
    user = create :user

    assert_raises do
      ContributorTeam::AddReviewer.(user)
    end
  end
end
