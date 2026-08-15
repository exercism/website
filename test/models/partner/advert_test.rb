require "test_helper"

class Partner::AdvertTest < ActiveSupport::TestCase
  test "for_track returns an advert without track slugs" do
    track = create :track
    advert = create :advert, status: :active

    assert_equal advert, Partner::Advert.for_track(track)
  end

  test "for_track prefers an advert that names the track" do
    track = create :track, slug: "ruby"
    create :advert, status: :active
    targeted = create :advert, status: :active, track_slugs: ["ruby"]

    assert_equal targeted, Partner::Advert.for_track(track)
  end

  test "for_track ignores an advert that names a different track" do
    track = create :track, slug: "ruby"
    generic = create :advert, status: :active
    create :advert, status: :active, track_slugs: ["python"]

    assert_equal generic, Partner::Advert.for_track(track)
  end

  test "for_track returns nil when there are no active adverts" do
    track = create :track
    create :advert, status: :pending

    assert_nil Partner::Advert.for_track(track)
  end

  test "for_track caches its decision" do
    track = create :track
    advert = create :advert, status: :active

    assert_equal advert, Partner::Advert.for_track(track)
    assert_equal advert.id, Rails.cache.read("partner/advert/for_track/#{track.slug}")
  end

  test "for_track caches the absence of an advert" do
    track = create :track

    assert_nil Partner::Advert.for_track(track)
    assert Rails.cache.exist?("partner/advert/for_track/#{track.slug}")
  end

  test "for_track caches per track" do
    ruby = create :track, slug: "ruby"
    python = create :track, slug: "python", title: "Python"
    generic = create :advert, status: :active
    targeted = create :advert, status: :active, track_slugs: ["python"]

    assert_equal generic, Partner::Advert.for_track(ruby)
    assert_equal targeted, Partner::Advert.for_track(python)
  end

  test "saving an advert clears the cached decision" do
    track = create :track
    advert = create :advert, status: :active

    assert_equal advert, Partner::Advert.for_track(track)

    advert.retired!

    assert_nil Rails.cache.read("partner/advert/for_track/#{track.slug}")
    assert_nil Partner::Advert.for_track(track)
  end

  test "clear_for_track_cache! clears every track's key" do
    ruby = create :track, slug: "ruby"
    python = create :track, slug: "python", title: "Python"
    create :advert, status: :active

    Partner::Advert.for_track(ruby)
    Partner::Advert.for_track(python)

    Partner::Advert.clear_for_track_cache!

    assert_nil Rails.cache.read("partner/advert/for_track/ruby")
    assert_nil Rails.cache.read("partner/advert/for_track/python")
  end
end
