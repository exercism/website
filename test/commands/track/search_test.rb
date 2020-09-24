require "test_helper"

class Badge::CreateTest < ActiveSupport::TestCase
  test "only include active tracks" do
    # Create one active and one inactive track
    track = create :track, active: true
    create :track, active: false

    assert_equal [track], Track::Search.()
  end

  test "wildcard search with criteria" do
    # Create one track with Ruby in the title
    track = create :track, title: "A Ruby Track"
    create :track, title: "A JS Track"

    assert_equal [track], Track::Search.(criteria: "ruby")
  end

  test "status raises without a user" do
    assert_raises TrackSearchStatusWithoutUserError do
      Track::Search.(status: :all)
    end
  end

  test "status raises unless its valid" do
    assert_raises TrackSearchInvalidStatusError do
      Track::Search.(status: :foobar, user: create(:user))
    end
  end

  test "status pivots correctly" do
    user = create :user
    joined = create :track
    create :user_track, user: user, track: joined
    unjoined = create :track

    assert_equal [joined, unjoined],
                 Track::Search.(status: :all, user: user)

    assert_equal [joined],
                 Track::Search.(status: :joined, user: user)

    assert_equal [unjoined],
                 Track::Search.(status: :unjoined, user: user)
  end
end
