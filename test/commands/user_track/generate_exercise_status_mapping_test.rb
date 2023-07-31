require "test_helper"

class UserTrack::GenerateExerciseStatusMappingTest < ActiveSupport::TestCase
  test "maps correctly" do
    track = create :track
    user_track = create(:user_track, track:)
    basics = create :concept, track:, slug: 'basics'
    exercise = create :practice_exercise, :random_slug, track:, position: 7
    exercise.practiced_concepts << basics

    mapping = UserTrack::GenerateExerciseStatusMapping.(user_track)

    expected = {
      slug: exercise.slug,
      url: Exercism::Routes.track_exercise_path(track.slug, exercise.slug),
      tooltip_url: Exercism::Routes.tooltip_track_exercise_url(track, exercise.slug),
      status: 'locked',
      type: 'practice',
      position: exercise.position
    }
    assert_equal expected, mapping['basics'][0]
  end

  test "sorts correctly" do
    track = create :track
    user_track = create(:user_track, track:)
    basics = create :concept, track:, slug: 'basics'
    concept = create :concept_exercise, :random_slug, track:, position: 11
    concept.taught_concepts << basics
    seven = create :practice_exercise, :random_slug, track:, position: 7
    five = create :practice_exercise, :random_slug, track:, position: 5
    nine = create :practice_exercise, :random_slug, track:, position: 9
    five.practiced_concepts << basics
    seven.practiced_concepts << basics
    nine.practiced_concepts << basics

    mapping = UserTrack::GenerateExerciseStatusMapping.(user_track)

    assert_equal [11, 5, 7, 9], (mapping['basics'].map { |e| e[:position] })
  end
end
