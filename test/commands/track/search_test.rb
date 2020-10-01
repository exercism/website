require "test_helper"

class Track::SearchTest < ActiveSupport::TestCase
  test "no options returns everything" do
    track = create :track, active: true

    assert_equal [track], Track::Search.()
  end

  test "active: only include active tracks" do
    # Create one active and one inactive track
    track = create :track, active: true
    create :track, active: false

    assert_equal [track], Track::Search.()
  end

  test "tags: filter appropriately" do
    strong_js_track = create :track, tags: ["compiles_to:javascript", "typing:strong"]
    strong_track = create :track, tags: ["typing:strong"]
    weak_track = create :track, tags: ["typing:weak"]

    assert_equal [strong_js_track, strong_track], Track::Search.(tags: ['typing:strong'])
    assert_equal [weak_track], Track::Search.(tags: ['typing:weak'])

    # Check both input orders to assert that the order of the tags passed in doesn't matter.
    assert_equal [strong_js_track], Track::Search.(tags: ['compiles_to:javascript', 'typing:strong'])
    assert_equal [strong_js_track], Track::Search.(tags: ['typing:strong', 'compiles_to:javascript'])
  end

  test "search: wildcard with criteria" do
    # Create one track with Ruby in the title
    track = create :track, title: "A Ruby Track"
    create :track, title: "A JS Track"

    assert_equal [track], Track::Search.(criteria: "ruby")
  end

  test "status: raises without a user" do
    assert_raises TrackSearchStatusWithoutUserError do
      Track::Search.(status: :all)
    end
  end

  test "status: raises unless its valid" do
    assert_raises TrackSearchInvalidStatusError do
      Track::Search.(status: :foobar, user: create(:user))
    end
  end

  test "status: pivots correctly" do
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

  test "order" do
    ruby = create :track, title: "Ruby"
    javascript = create :track, title: "Javascript"
    assembly = create :track, title: "Assembly"

    assert_equal [assembly, javascript, ruby], Track::Search.()
  end
end
