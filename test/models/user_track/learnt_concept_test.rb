require 'test_helper'

class UserTrack::LearntConceptTest < ActiveSupport::TestCase
  test "wired in correctly" do
    user_track = create :user_track
    concept = create :track_concept
    learnt_concept = create :user_track_learnt_concept,
      user_track: user_track,
      concept: concept

    assert_equal user_track, learnt_concept.user_track
    assert_equal concept, learnt_concept.concept
  end
end
