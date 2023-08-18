require "test_helper"

class Track::Trophies::CompletedFiveHardExercisesTrophyTest < ActiveSupport::TestCase
  test "award?" do
    user = create :user
    track = create :track
    trophy = create :completed_five_hard_exercises_trophy

    create(:user_track, user:, track:)

    # We need to get hold of the user track like this as otherwise
    # we'd end up with the code being tested using a different,
    # cached version of the user track and we could not reset the
    # summary data
    user_track = UserTrack.for!(user, track)

    easy_exercises = create_list(:practice_exercise, 7, :random_slug, track:, difficulty: 2)
    medium_exercises = create_list(:practice_exercise, 8, :random_slug, track:, difficulty: 5)
    hard_exercises = create_list(:practice_exercise, 9, :random_slug, track:, difficulty: 8)

    # Completing five easy solutions does not count
    easy_exercises.each { |exercise| create(:practice_solution, :completed, exercise:, user:) }
    user_track.reset_summary!
    refute trophy.award?(user, track)

    # Completing five medium solutions does not count
    medium_exercises.each { |exercise| create(:practice_solution, :completed, exercise:, user:) }
    user_track.reset_summary!
    refute trophy.award?(user, track)

    # Completing four medium solutions does not count
    hard_exercises[0..3].each { |exercise| create(:practice_solution, :completed, exercise:, user:) }
    user_track.reset_summary!
    refute trophy.award?(user, track)

    # Starting fifth hard solution does not count
    solution = create(:practice_solution, :started, exercise: hard_exercises[4], user:)
    user_track.reset_summary!
    refute trophy.award?(user, track)

    # Iterating fifth hard solution does not count
    solution.update(status: :iterated)
    user_track.reset_summary!
    refute trophy.award?(user, track)

    # Completing fifth hard solution counts
    solution.update(completed_at: Time.current)
    user_track.reset_summary!
    assert trophy.award?(user, track)
  end

  test "reseed! sets valid_track_slugs to tracks with five hard exercises" do
    track = create :track
    trophy = create :completed_five_hard_exercises_trophy

    # Sanity check
    assert_empty trophy.valid_track_slugs

    # Four difficult exercises don't count
    create_list(:practice_exercise, 4, difficulty: 8, track:)
    trophy.reseed!
    assert_empty trophy.valid_track_slugs

    # Easy exercises don't count
    create(:practice_exercise, difficulty: 1, track:)
    create(:practice_exercise, difficulty: 2, track:)
    create(:practice_exercise, difficulty: 3, track:)
    trophy.reseed!
    assert_empty trophy.valid_track_slugs

    # Medium exercises don't count
    create(:practice_exercise, difficulty: 4, track:)
    create(:practice_exercise, difficulty: 5, track:)
    create(:practice_exercise, difficulty: 6, track:)
    create(:practice_exercise, difficulty: 7, track:)
    trophy.reseed!
    assert_empty trophy.valid_track_slugs

    # Hard exercise counts
    exercise = create(:practice_exercise, difficulty: 8, track:)
    trophy.reseed!
    assert_equal [track.slug], trophy.valid_track_slugs

    exercise.update(difficulty: 9)
    trophy.reseed!
    assert_equal [track.slug], trophy.valid_track_slugs

    # Ignore other track without five hard exercises
    other_track = create :track, slug: 'fsharp'
    trophy.reseed!
    assert_equal [track.slug], trophy.valid_track_slugs

    # Include all tracks that have five hard exercises
    create_list(:practice_exercise, 5, difficulty: 9, track: other_track)
    trophy.reseed!
    assert_equal [track.slug, other_track.slug].sort, trophy.valid_track_slugs.sort
  end

  test "worth_queuing?" do
    track = create :track
    trophy = create :completed_five_hard_exercises_trophy
    exercise = create :practice_exercise

    # Don't queue easy difficulty exercise
    (1..3).each do |difficulty|
      exercise.update(difficulty:)
      refute trophy.worth_queuing?(track:, exercise:)
    end

    # Don't queue medium difficulty exercise
    (4..7).each do |difficulty|
      exercise.update(difficulty:)
      refute trophy.worth_queuing?(track:, exercise:)
    end

    # Queue hard difficulty exercise
    (8..9).each do |difficulty|
      exercise.update(difficulty:)
      assert trophy.worth_queuing?(track:, exercise:)
    end

    exercise.update(difficulty: 9)
  end

  test "worth_queuing? does not require exercise in context" do
    track = create :track
    trophy = create :completed_five_hard_exercises_trophy

    assert trophy.worth_queuing?(track:)
  end
end
