require "test_helper"

class UserTrack::UpdateTrainerTest < ActiveSupport::TestCase
  test "become trainer" do
    user = create :user

    # Sanity check
    refute user.trainer?

    create(:user_track, user:, reputation: 77)
    User::BecomeTrainer.(user)

    user = User.find(user.id) # Workaround caching
    assert user.data.trainer?
  end

  test "raises when trying to become trainer whilst not meeting requirements" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:, reputation: 12)

    assert_raises TrainerCriteriaNotFulfilledError do
      User::BecomeTrainer.(user)
    end
  end
end
