require 'test_helper'

class Icons::DetermineUrlForTest < ActiveSupport::TestCase
  test "returns the bucket url when the icon exists" do
    stub_manifest(["exercises/bob.svg"])

    assert_equal "https://assets.exercism.org/exercises/bob.svg",
      Icons::DetermineUrlFor.("exercises/bob.svg", Icons::DetermineUrlFor::MISSING_EXERCISE_ICON)
  end

  test "returns the fallback when the icon doesn't exist" do
    stub_manifest(["exercises/bob.svg"])

    url = Icons::DetermineUrlFor.("exercises/flower-field.svg", Icons::DetermineUrlFor::MISSING_EXERCISE_ICON)
    assert_includes url, "missing-exercise"
    refute_includes url, "flower-field"
  end

  test "assumes the icon exists when the manifest is unavailable" do
    stub_request(:get, "https://assets.exercism.org/manifest.json").to_return(status: 500)
    Sentry.stubs(:capture_exception)

    assert_equal "https://assets.exercism.org/exercises/flower-field.svg",
      Icons::DetermineUrlFor.("exercises/flower-field.svg", Icons::DetermineUrlFor::MISSING_EXERCISE_ICON)
  end

  test "exercise and track icon urls use the manifest" do
    stub_manifest(["tracks/ruby.svg"])

    track = create :track, slug: :ruby
    exercise = create :practice_exercise, track:, slug: :flower_field, icon_name: 'flower-field'

    assert_equal "https://assets.exercism.org/tracks/ruby.svg", track.icon_url
    assert_includes exercise.icon_url, "missing-exercise"
  end

  def stub_manifest(paths)
    stub_request(:get, "https://assets.exercism.org/manifest.json").
      to_return(status: 200, body: paths.to_json)
  end
end
