require "test_helper"

class UpdateAutomatorRolesJobTest < ActiveJob::TestCase
  test "updates all automators" do
    track_1 = create :track, :random_slug
    track_2 = create :track, :random_slug
    user_1 = create :user, roles: []
    user_2 = create :user, roles: []
    create(:user_track_mentorship, :automator, user: user_1, track: track_1)
    create(:user_track_mentorship, user: user_1, track: track_2)
    create(:user_track_mentorship, :automator, user: user_2, track: track_2)

    User::UpdateAutomatorRole.expects(:call).with(user_1, track_1).once
    User::UpdateAutomatorRole.expects(:call).with(user_2, track_2).once
    User::UpdateAutomatorRole.expects(:call).with(user_1, track_2).never

    UpdateAutomatorRolesJob.perform_now
  end
end
