require "test_helper"

class UserTrack::ResetTest < ActiveSupport::TestCase
  test "creates user_track" do
    system_user = create :user, :system

    user = create :user
    track = create :track
    solution_1 = create :concept_solution, track: track, user: user
    solution_2 = create :practice_solution, track: track, user: user

    user_track = create :user_track, user: user, track: track

    UserTrack::Reset.(user_track)

    assert_equal system_user, solution_1.reload.user
    assert_equal system_user, solution_2.reload.user
  end
end
