require "test_helper"

# These pages are cached at the Cloudflare edge for a day for anonymous
# visitors. Two properties make that safe, and both are asserted here for
# every page:
#
# 1. The action opts into the long edge TTL.
# 2. The anonymous response sets no cookies. If it ever did, Cloudflare would
#    stop caching the page and the caching would silently do nothing.
class Tracks::PublicCachingTest < ActionDispatch::IntegrationTest
  def assert_cached_and_cookieless(url)
    ApplicationController.any_instance.expects(:cache_public_action!).with(edge_ttl: 1.day).at_least_once

    get url

    assert response.headers['Set-Cookie'].blank?
  end

  test "tracks index" do
    create :track

    assert_cached_and_cookieless tracks_url
  end

  test "track show" do
    track = create :track

    assert_cached_and_cookieless track_url(track)
  end

  test "track build" do
    track = create :track
    Tooling::RetrieveSha.stubs(:call).returns('sha')
    Track::UpdateBuildStatus.(track)

    assert_cached_and_cookieless track_build_url(track)
  end

  test "exercises index" do
    track = create :track
    create(:practice_exercise, track:)

    assert_cached_and_cookieless track_exercises_url(track)
  end

  test "concepts index" do
    track = create :track, course: true
    create(:concept, track:)

    assert_cached_and_cookieless track_concepts_url(track)
  end

  test "dig deeper" do
    track = create :track
    exercise = create(:practice_exercise, track:)

    assert_cached_and_cookieless track_exercise_dig_deeper_url(track, exercise)
  end

  test "approach show" do
    track = create :track
    exercise = create(:practice_exercise, track:)
    approach = create(:exercise_approach, exercise:)

    assert_cached_and_cookieless track_exercise_approach_url(track, exercise, approach)
  end

  test "article show" do
    track = create :track
    exercise = create(:practice_exercise, track:)
    article = create(:exercise_article, exercise:)

    assert_cached_and_cookieless track_exercise_article_url(track, exercise, article)
  end
end
