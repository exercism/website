require "test_helper"

class UserTrack::GenerateConceptExerciseMappingTest < ActiveSupport::TestCase
  test "generates concept-exercise mapping for empty track" do
    _, user_track = setup_user_track

    assert_equal(
      {},
      UserTrack::GenerateConceptExerciseMapping.(user_track)
    )
  end

  test "generates concept-exercise mapping for one-concept track, no solution" do
    track, user_track = setup_user_track
    basics, = setup_concepts(track, 'basics')
    lasagna, = setup_concept_exercises(track, 'lasagna')
    lasagna.taught_concepts << basics

    assert_equal(
      { 'basics' => { exercises: 1, exercises_completed: 0 } },
      UserTrack::GenerateConceptExerciseMapping.(user_track)
    )
  end

  test "generates concept-exercise mapping for one-concept track with practice exercise, no solution" do
    track, user_track = setup_user_track
    basics, = setup_concepts(track, 'basics')

    lasagna, = setup_concept_exercises(track, 'lasagna')
    lasagna.taught_concepts << basics

    vegetarian_lasagna, = setup_practice_exercises(track, 'vegetarian_lasagna')
    vegetarian_lasagna.prerequisites << basics

    assert_equal(
      { 'basics' => { exercises: 2, exercises_completed: 0 } },
      UserTrack::GenerateConceptExerciseMapping.(user_track)
    )
  end

  test "generates concept-exercise mapping for one-concept, with concept solution" do
    track, user_track = setup_user_track
    basics, = setup_concepts(track, 'basics')

    lasagna, = setup_concept_exercises(track, 'lasagna')
    lasagna.taught_concepts << basics

    create :concept_solution, user: user_track.user, exercise: lasagna, completed_at: Time.current

    assert_equal(
      { 'basics' => { exercises: 1, exercises_completed: 1 } },
      UserTrack::GenerateConceptExerciseMapping.(user_track)
    )
  end

  test "generates concept-exercise mapping for one-concept, one-practice, with practice solution" do
    track, user_track = setup_user_track
    basics, = setup_concepts(track, 'basics')

    lasagna, = setup_concept_exercises(track, 'lasagna')
    lasagna.taught_concepts << basics

    vegetarian_lasagna, = setup_practice_exercises(track, 'vegetarian_lasagna')
    vegetarian_lasagna.prerequisites << basics

    create :practice_solution, user: user_track.user, exercise: vegetarian_lasagna, completed_at: Time.current

    assert_equal(
      { 'basics' => { exercises: 2, exercises_completed: 1 } },
      UserTrack::GenerateConceptExerciseMapping.(user_track)
    )
  end

  test "generates concept-exercise mapping for one-concept, one-practice, with all solution" do
    track, user_track = setup_user_track
    basics, = setup_concepts(track, 'basics')

    lasagna, = setup_concept_exercises(track, 'lasagna')
    lasagna.taught_concepts << basics

    create :concept_solution, user: user_track.user, exercise: lasagna, completed_at: Time.current

    vegetarian_lasagna, = setup_practice_exercises(track, 'vegetarian_lasagna')
    vegetarian_lasagna.prerequisites << basics

    create :practice_solution, user: user_track.user, exercise: vegetarian_lasagna, completed_at: Time.current

    assert_equal(
      { 'basics' => { exercises: 2, exercises_completed: 2 } },
      UserTrack::GenerateConceptExerciseMapping.(user_track)
    )
  end

  private
  def setup_user_track
    track = create :track
    user_track = create :user_track, track: track

    [track, user_track]
  end

  def setup_concepts(track, *slugs)
    setup_from_factory(track, :track_concept, slugs)
  end

  def setup_concept_exercises(track, *slugs)
    setup_from_factory(track, :concept_exercise, slugs)
  end

  def setup_practice_exercises(track, *slugs)
    setup_from_factory(track, :practice_exercise, slugs)
  end

  def setup_from_factory(track, type, slugs)
    slugs.map { |slug| create type, slug: slug, track: track }
  end
end
