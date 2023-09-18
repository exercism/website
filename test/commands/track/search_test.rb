require "test_helper"

class Track::SearchTest < ActiveSupport::TestCase
  test "no options returns everything" do
    track = create :track, :random_slug, active: true

    assert_equal [track], Track::Search.()
  end

  test "active: only include active tracks" do
    # Create one active and one inactive track
    track = create :track, :random_slug, active: true
    create :track, :random_slug, active: false

    assert_equal [track], Track::Search.()
  end

  test "tags: filter appropriately" do
    strong_js_track = create :track, :random_slug, tags: ["compiles_to:javascript", "typing:strong"]
    strong_track = create :track, :random_slug, tags: ["typing:strong"]
    weak_track = create :track, :random_slug, tags: ["typing:weak"]

    assert_equal [strong_js_track, strong_track], Track::Search.(tags: ['typing:strong'])
    assert_equal [weak_track], Track::Search.(tags: ['typing:weak'])

    # Check both input orders to assert that the order of the tags passed in doesn't matter.
    assert_equal [strong_js_track], Track::Search.(tags: ['compiles_to:javascript', 'typing:strong'])
    assert_equal [strong_js_track], Track::Search.(tags: ['typing:strong', 'compiles_to:javascript'])
  end

  test "search: wildcard with criteria matches title" do
    # Create one track with Ruby in the title
    track = create :track, :random_slug, title: "A Ruby Track"
    create :track, :random_slug, title: "A JS Track"

    assert_equal [track], Track::Search.(criteria: "ruby")
  end

  test "search: wildcard with criteria matches slug" do
    # Create one track with Ruby in the title
    track = create :track, :random_slug, title: "A C# Track", slug: 'csharp'
    create :track, :random_slug, title: "A Ruby Track", slug: 'ruby'

    assert_equal [track], Track::Search.(criteria: "csharp")
  end

  test "status: raises without a user" do
    assert_raises TrackSearchStatusWithoutUserError do
      Track::Search.(status: :all)
    end
  end

  test "status: raises unless it's valid" do
    assert_raises TrackSearchInvalidStatusError do
      Track::Search.(status: :foobar, user: create(:user))
    end
  end

  test "status: pivots correctly" do
    user = create :user
    joined = create :track, :random_slug
    create :user_track, user:, track: joined
    unjoined = create :track, :random_slug

    assert_equal [joined, unjoined],
      Track::Search.(status: :all, user:)

    assert_equal [joined],
      Track::Search.(status: :joined, user:)

    assert_equal [unjoined],
      Track::Search.(status: :unjoined, user:)
  end
end
