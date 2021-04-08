require 'test_helper'

class SerializeTrackTest < ActiveSupport::TestCase
  test "without user" do
    track_updated_at = Time.current - 1.week
    track = create :track, tags: ["execution_mode/compiled", "runtime/clr"], updated_at: track_updated_at

    num_concept_exercises = 3
    num_concepts = num_concept_exercises + 1
    num_practice_exercises = 7

    # Create num_concept_exercises, each with a concept
    # and then add one extra concept to the last exercise
    num_concept_exercises.times do
      create(:track_concept, track: track)
      create(:concept_exercise, track: track)
    end
    create(:track_concept, track: track)

    # Create num_practice_exercises practice exercises
    num_practice_exercises.times { create :practice_exercise, track: track }

    expected = {
      id: track.slug,
      title: track.title,
      num_concepts: num_concepts,
      num_exercises: num_concept_exercises + num_practice_exercises,
      web_url: "https://test.exercism.io/tracks/#{track.slug}",
      icon_url: track.icon_url,
      updated_at: track_updated_at.iso8601,
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
    updated_at = Time.current - 1.minute
    track = create :track, updated_at: Time.current - 2.months
    user_track = create :user_track, updated_at: updated_at, track: track

    data = SerializeTrack.(track, user_track)

    assert_equal updated_at.iso8601, data[:updated_at]
  end

  test "with user joined and progressed" do
    track = create :track

    num_concept_exercises = 4
    num_practice_exercises = 7

    # Create num_concept_exercises, each with a concept
    # and then add one extra concept to the last exercise
    ces = Array.new(num_concept_exercises).map { create(:concept_exercise, :random_slug, track: track) }

    # Create num_practice_exercises practice exercises
    pes = Array.new(num_practice_exercises).map { create :practice_exercise, :random_slug, track: track }

    # Create a concept that the user has acquired
    concept = create(:track_concept, track: track)
    ces.first.taught_concepts << concept

    user = create :user
    user_track = create :user_track, user: user, track: track

    # TODO: Change to be completed when that is in the db schema
    # and add a case where it's not completed to check the flag is
    # being used correctly.
    create :concept_solution, exercise: ces[0], user: user, completed_at: Time.current
    create :concept_solution, exercise: ces[1], user: user
    create :practice_solution, exercise: pes[0], user: user
    create :practice_solution, exercise: pes[1], user: user, completed_at: Time.current
    create :practice_solution, exercise: pes[2], user: user, completed_at: Time.current
    create :user_track_learnt_concept, user_track: user_track, concept: concept

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
    ut_id = create(:user_track, user: user, track: track).id
    solution = create :practice_solution, user: user, track: track
    discussion = create :mentor_discussion, solution: solution

    # False with none
    track_data = SerializeTrack.(track, UserTrack.find(ut_id))
    refute track_data[:has_notifications]

    # Override works
    track_data = SerializeTrack.(track, UserTrack.find(ut_id), has_notifications: true)
    assert track_data[:has_notifications]

    # True if there is one
    create :mentor_started_discussion_notification, user: user, params: { discussion: discussion }, status: :unread
    track_data = SerializeTrack.(track, UserTrack.find(ut_id))
    assert track_data[:has_notifications]
  end
end
