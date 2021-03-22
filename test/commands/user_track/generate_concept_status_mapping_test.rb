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

  test "concepts following incomplete concepts are :unavailable" do
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
        'booleans' => :unavailable,
        'atoms' => :unavailable
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
    create :user_track_learnt_concept, user_track: user_track, concept: basics

    assert_equal(
      {
        'basics' => :complete,
        'booleans' => :available,
        'atoms' => :unavailable
      },
      UserTrack::GenerateConceptStatusMapping.(user_track)
    )
  end

  test "concepts with multiple first-level pre-reqs are unavailable" do
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
        'atoms' => :unavailable
      },
      UserTrack::GenerateConceptStatusMapping.(user_track)
    )
  end

  test "concepts with two pre-reqs are :unavailable unless both are complete" do
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
    create :user_track_learnt_concept, user_track: user_track, concept: basics

    assert_equal(
      {
        'basics' => :complete,
        'booleans' => :available,
        'atoms' => :unavailable
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
    create :user_track_learnt_concept, user_track: user_track, concept: basics
    create :user_track_learnt_concept, user_track: user_track, concept: booleans

    assert_equal(
      {
        'basics' => :complete,
        'booleans' => :complete,
        'atoms' => :available
      },
      UserTrack::GenerateConceptStatusMapping.(user_track)
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

  def setup_from_factory(track, type, slugs)
    slugs.map { |slug| create type, slug: slug, track: track }
  end
end
