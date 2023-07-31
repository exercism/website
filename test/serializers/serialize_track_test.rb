require 'test_helper'

class SerializeTrackTest < ActiveSupport::TestCase
  test "without user" do
    track = create :track, tags: ["execution_mode/compiled", "runtime/clr"]

    num_concept_exercises = 3
    num_concepts = num_concept_exercises + 1
    num_practice_exercises = 7

    # Create num_concept_exercises, each with a concept
    # and then add one extra concept to the last exercise
    num_concept_exercises.times do
      concept = create(:concept, track:)
      exercise = create(:concept_exercise, track:)
      create :exercise_taught_concept, exercise:, concept:
    end
    ConceptExercise.last.taught_concepts << (create :concept, track:)

    # Create num_practice_exercises practice exercises
    num_practice_exercises.times { create :practice_exercise, track: }

    track.reload

    expected = {
      slug: track.slug,
      title: track.title,
      course: track.course?,
      num_concepts:,
      num_exercises: num_concept_exercises + num_practice_exercises,
      web_url: "https://test.exercism.org/tracks/#{track.slug}",
      icon_url: track.icon_url,
      last_touched_at: nil,
      tags: ["Compiled", "Common Language Runtime (.NET)"],

      # TODO: Set this correctly
      is_new: true,

      links: {
        self: Exercism::Routes.track_url(track),
        exercises: Exercism::Routes.track_exercises_url(track),
        concepts: Exercism::Routes.track_concepts_url(track)
      }
    }

    assert_equal expected, SerializeTrack.(track, nil)
  end

  test "with user not joined" do
    track = create :track

    track_data = SerializeTrack.(track, nil)

    assert_nil track_data[:is_joined]
    assert_nil track_data[:nnum_completed_concept_exercises]
    assert_nil track_data[:num_completed_practice_exercises]
    assert_nil track_data[:has_notifications]
  end

  test "updated_at is user_track.updated_at" do
    last_touched_at = Time.current - 1.minute
    track = create :track, updated_at: Time.current - 2.months
    user_track = create(:user_track, last_touched_at:, track:)

    data = SerializeTrack.(track, user_track)

    assert_equal last_touched_at.iso8601, data[:last_touched_at]
  end

  test "is_new is true for new track" do
    track = create :track, created_at: Time.current - 5.months
    user_track = create(:user_track, track:)

    data = SerializeTrack.(track, user_track)

    assert data[:is_new]
  end

  test "is_new is false for old track" do
    track = create :track, created_at: Time.current - 1.year
    user_track = create(:user_track, track:)

    data = SerializeTrack.(track, user_track)

    refute data[:is_new]
  end

  test "with user joined and progressed" do
    track = create :track

    num_concept_exercises = 4
    num_practice_exercises = 7

    # Create num_concept_exercises, each with a concept
    # and then add one extra concept to the last exercise
    ces = Array.new(num_concept_exercises).map { create(:concept_exercise, :random_slug, track:) }

    # Create num_practice_exercises practice exercises
    pes = Array.new(num_practice_exercises).map { create(:practice_exercise, :random_slug, track:) }

    # Create a concept that the user has acquired
    concept = create(:concept, track:)
    ces.first.taught_concepts << concept

    user = create :user
    user_track = create(:user_track, user:, track:)

    # TODO: Change to be completed when that is in the db schema
    # and add a case where it's not completed to check the flag is
    # being used correctly.
    create(:concept_solution, :completed, exercise: ces[0], user:)
    create(:concept_solution, exercise: ces[1], user:)
    create(:practice_solution, exercise: pes[0], user:)
    create(:practice_solution, :completed, exercise: pes[1], user:)
    create(:practice_solution, :completed, exercise: pes[2], user:)

    # Remove caching
    user_track = UserTrack.find(user_track.id).reload
    track_data = SerializeTrack.(track, user_track)

    assert track_data[:is_joined]
    assert_equal 1, track_data[:num_learnt_concepts]
    assert_equal 3, track_data[:num_completed_exercises]
  end

  test "tags are always an array" do
    track = create :track, tags: nil
    track_data = SerializeTrack.(track, nil)

    assert_empty track_data[:tags]
  end

  test "with notifications" do
    user = create :user
    track = create :track, :random_slug
    ut_id = create(:user_track, user:, track:).id
    solution = create(:practice_solution, user:, track:)
    discussion = create(:mentor_discussion, solution:)

    # False with none
    track_data = SerializeTrack.(track, UserTrack.find(ut_id))
    refute track_data[:has_notifications]

    # Override works
    track_data = SerializeTrack.(track, UserTrack.find(ut_id), has_notifications: true)
    assert track_data[:has_notifications]

    # True if there is one
    create :mentor_started_discussion_notification, user:, params: { discussion: }, status: :unread
    track_data = SerializeTrack.(track, UserTrack.find(ut_id))
    assert track_data[:has_notifications]
  end
end
