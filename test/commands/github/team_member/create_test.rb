require "test_helper"

class Github::TeamMember::CreateTest < ActiveSupport::TestCase
  test "creates team member" do
    github_uid = '137131'
    team_name = 'fsharp'
    user = create(:user, uid: github_uid)

    team_name_member = Github::TeamMember::Create.(user, team_name)

    assert_equal 1, Github::TeamMember.count
    assert_equal user, team_name_member.user
    assert_equal team_name, team_name_member.team_name
  end

  test "update maintainer role" do
    github_uid = '137131'
    team_name = 'fsharp'

    create(:track, slug: team_name)
    user = create(:user, uid: github_uid)
    User::UpdateMaintainer.expects(:call).with(user).once

    team_name_member = Github::TeamMember::Create.(user, team_name)

    assert_equal 1, Github::TeamMember.count
    assert_equal user, team_name_member.user
    assert_equal team_name, team_name_member.team_name
  end

  test "don't update maintainer when team is not track team" do
    github_uid = '137131'
    team_name = 'configlet'
    user = create(:user, uid: github_uid)

    User::UpdateMaintainer.expects(:call).with(user).never

    Github::TeamMember::Create.(user, team_name)
  end

  test "noop when already created" do
    github_uid = '137131'
    team_name = 'fsharp'
    user = create(:user, uid: github_uid)
    create(:github_team_member, team_name:, user:)

    User::UpdateMaintainer.expects(:call).with(user).never

    Github::TeamMember::Create.(user, team_name)
  end

  test "idempotent" do
    user_id = '137131'
    team_name = 'fsharp'
    user = create(:user, uid: user_id)

    assert_idempotent_command do
      Github::TeamMember::Create.(user, team_name)
    end

    assert_equal 1, Github::TeamMember.count
    assert Github::TeamMember.where(user:, team_name:).exists?
  end
end
