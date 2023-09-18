require "test_helper"

class UserTrack::DestroysTest < ActiveSupport::TestCase
  test "resets and destroys everything" do
    freeze_time do
      user = create :user
      user_track = create(:user_track, user:)

      UserTrack::Reset.expects(:call).with(user_track)

      UserTrack::Destroy.(user_track)

      assert_raises ActiveRecord::RecordNotFound do
        user_track.reload
      end
    end
  end
end
