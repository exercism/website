require "test_helper"

class UserTrack::GenerateConceptStatusMappingTest < ActiveSupport::TestCase
  test "generates concepts for empty track" do
    _, user_track = setup_user_track

    assert_empty(
      UserTrack::GenerateConceptStatusMapping.(user_track)
    )
  end

  test "concepts without prerequisite are :available" do
    track, user_track = setup_user_track
    setup_concepts(track, 'basics')

    assert_equal(
      { 'basics' => :available },
      UserTrack::GenerateConceptStatusMapping.(user_track)
    )
  end

  test "concepts following incomplete concepts are :locked" do
    track, user_track = setup_user_track
    basics, booleans, atoms = setup_concepts(track, 'basics', 'booleans', 'atoms')
    lasagna, pacman, logger = setup_concept_exercises(track, 'lasagna', 'pacman', 'logger')

    # Set up exercises
    lasagna.taught_concepts << basics

    pacman.taught_concepts << booleans
    pacman.prerequisites << basics

    logger.taught_concepts << atoms
    logger.prerequisites << booleans

    assert_equal(
      {
        'basics' => :available,
        'booleans' => :locked,
        'atoms' => :locked
      },
      UserTrack::GenerateConceptStatusMapping.(user_track)
    )
  end

  test "concepts following complete concepts are :available" do
    track, user_track = setup_user_track
    basics, booleans, atoms = setup_concepts(track, 'basics', 'booleans', 'atoms')
    lasagna, pacman, logger = setup_concept_exercises(track, 'lasagna', 'pacman', 'logger')

    lasagna.taught_concepts << basics

    pacman.taught_concepts << booleans
    pacman.prerequisites << basics

    logger.taught_concepts << atoms
    logger.prerequisites << booleans

    # Simulate learning concepts
    create :concept_solution, user: user_track.user, exercise: lasagna, completed_at: Time.current

    assert_equal(
      {
        'basics' => :mastered,
        'booleans' => :available,
        'atoms' => :locked
      },
      UserTrack::GenerateConceptStatusMapping.(user_track)
    )
  end

  test "concepts with multiple first-level pre-reqs are locked" do
    track, user_track = setup_user_track
    basics, booleans, atoms = setup_concepts(track, 'basics', 'booleans', 'atoms')
    lasagna, pacman, logger = setup_concept_exercises(track, 'lasagna', 'pacman', 'logger')

    # Set up exercises
    lasagna.taught_concepts << basics

    pacman.taught_concepts << booleans

    logger.taught_concepts << atoms
    logger.prerequisites << basics
    logger.prerequisites << booleans

    assert_equal(
      {
        'basics' => :available,
        'booleans' => :available,
        'atoms' => :locked
      },
      UserTrack::GenerateConceptStatusMapping.(user_track)
    )
  end

  test "concepts with two pre-reqs are :locked unless both are complete" do
    track, user_track = setup_user_track
    basics, booleans, atoms = setup_concepts(track, 'basics', 'booleans', 'atoms')
    lasagna, pacman, logger = setup_concept_exercises(track, 'lasagna', 'pacman', 'logger')

    # Set up exercises
    lasagna.taught_concepts << basics

    pacman.taught_concepts << booleans

    logger.taught_concepts << atoms
    logger.prerequisites << basics
    logger.prerequisites << booleans

    # Simulate learning concepts
    create :concept_solution, user: user_track.user, exercise: lasagna, completed_at: Time.current

    assert_equal(
      {
        'basics' => :mastered,
        'booleans' => :available,
        'atoms' => :locked
      },
      UserTrack::GenerateConceptStatusMapping.(user_track)
    )
  end

  test "concept with two pre-reqs is available when all pre-reqs complete" do
    track, user_track = setup_user_track
    basics, booleans, atoms = setup_concepts(track, 'basics', 'booleans', 'atoms')
    lasagna, pacman, logger = setup_concept_exercises(track, 'lasagna', 'pacman', 'logger')

    # Set up exercises
    lasagna.taught_concepts << basics

    pacman.taught_concepts << booleans

    logger.taught_concepts << atoms
    logger.prerequisites << basics
    logger.prerequisites << booleans

    # Simulate learning concepts
    create :concept_solution, user: user_track.user, exercise: lasagna, completed_at: Time.current
    create :concept_solution, user: user_track.user, exercise: pacman, completed_at: Time.current

    assert_equal(
      {
        'basics' => :mastered,
        'booleans' => :mastered,
        'atoms' => :available
      },
      UserTrack::GenerateConceptStatusMapping.(user_track)
    )
  end

  test "learnt" do
    track, user_track = setup_user_track
    basics = create :concept, track:, slug: :basics
    lasagna = create(:concept_exercise, slug: :lasagna, track:)
    bob = create(:practice_exercise, slug: :bob, track:)

    # Set up exercises
    lasagna.taught_concepts << basics
    bob.practiced_concepts << basics

    # Simulate learning concepts
    create :concept_solution, user: user_track.user, exercise: lasagna, completed_at: Time.current

    assert_equal(
      {
        'basics' => :learnt
      },
      UserTrack::GenerateConceptStatusMapping.(user_track)
    )
  end

  private
  def setup_user_track
    track = create :track
    user_track = create(:user_track, track:)
    hello_world_solution = create :hello_world_solution, :completed, track:, user: user_track.user

    [track, user_track, hello_world_solution]
  end

  def setup_concepts(track, *slugs)
    setup_from_factory(track, :concept, slugs)
  end

  def setup_concept_exercises(track, *slugs)
    setup_from_factory(track, :concept_exercise, slugs)
  end

  def setup_from_factory(track, type, slugs)
    slugs.map { |slug| create type, slug:, track: }
  end
end
