require "test_helper"

class UserTrack::GenerateConceptsStatusTest < ActiveSupport::TestCase
  test "generates concepts for empty track" do
    track = create :track
    user_track = create :user_track, track: track

    assert_equal(
      {},
      ::UserTrack::GenerateConceptsStatus.(user_track)
    )
  end

  test "concepts without prerequisite are :unlocked" do
    track = create :track
    user_track = create :user_track, track: track

    create :track_concept, slug: 'basics', track: track

    assert_equal(
      { 'basics' => :unlocked },
      ::UserTrack::GenerateConceptsStatus.(user_track)
    )
  end

  test "concepts following incomplete concepts are :locked" do
    track = create :track
    user_track = create :user_track, track: track

    basics = create :track_concept, slug: 'basics', track: track
    booleans = create :track_concept, slug: 'booleans', track: track
    atoms = create :track_concept, slug: 'atoms', track: track

    lasagna = create :concept_exercise, track: track
    lasagna.taught_concepts << basics

    pacman = create :concept_exercise, track: track
    pacman.taught_concepts << booleans
    pacman.prerequisites << basics

    logger = create :concept_exercise, track: track
    logger.taught_concepts << atoms
    logger.prerequisites << booleans

    assert_equal(
      {
        'basics' => :unlocked,
        'booleans' => :locked,
        'atoms' => :locked
      },
      ::UserTrack::GenerateConceptsStatus.(user_track)
    )
  end

  test "concepts following complete concepts are :unlocked" do
    track = create :track
    user_track = create :user_track, track: track

    # Set up concepts

    basics = create :track_concept, slug: 'basics', track: track
    booleans = create :track_concept, slug: 'booleans', track: track
    atoms = create :track_concept, slug: 'atoms', track: track

    # Set up exercises

    lasagna = create :concept_exercise, track: track
    lasagna.taught_concepts << basics

    pacman = create :concept_exercise, track: track
    pacman.taught_concepts << booleans
    pacman.prerequisites << basics

    logger = create :concept_exercise, track: track
    logger.taught_concepts << atoms
    logger.prerequisites << booleans

    # learn concepts

    create :user_track_learnt_concept, user_track: user_track, concept: basics

    assert_equal(
      {
        'basics' => :complete,
        'booleans' => :unlocked,
        'atoms' => :locked
      },
      ::UserTrack::GenerateConceptsStatus.(user_track)
    )
  end

  test "concepts with multiple first-level pre-reqs are locked" do
    track = create :track
    user_track = create :user_track, track: track

    # Set up concepts

    basics = create :track_concept, slug: 'basics', track: track
    booleans = create :track_concept, slug: 'booleans', track: track
    atoms = create :track_concept, slug: 'atoms', track: track

    # Set up exercises

    lasagna = create :concept_exercise, track: track
    lasagna.taught_concepts << basics

    pacman = create :concept_exercise, track: track
    pacman.taught_concepts << booleans

    logger = create :concept_exercise, track: track
    logger.taught_concepts << atoms
    logger.prerequisites << basics
    logger.prerequisites << booleans

    # Before any are completed

    assert_equal(
      {
        'basics' => :unlocked,
        'booleans' => :unlocked,
        'atoms' => :locked
      },
      ::UserTrack::GenerateConceptsStatus.(user_track)
    )
  end

  test "concepts with two prereqs are :locked unless both are complete" do
    track = create :track
    user_track = create :user_track, track: track

    # Set up concepts

    basics = create :track_concept, slug: 'basics', track: track
    booleans = create :track_concept, slug: 'booleans', track: track
    atoms = create :track_concept, slug: 'atoms', track: track

    # Set up exercises

    lasagna = create :concept_exercise, track: track
    lasagna.taught_concepts << basics

    pacman = create :concept_exercise, track: track
    pacman.taught_concepts << booleans

    logger = create :concept_exercise, track: track
    logger.taught_concepts << atoms
    logger.prerequisites << basics
    logger.prerequisites << booleans

    # One parent is completed

    create :user_track_learnt_concept, user_track: user_track, concept: basics

    assert_equal(
      {
        'basics' => :complete,
        'booleans' => :unlocked,
        'atoms' => :locked
      },
      ::UserTrack::GenerateConceptsStatus.(user_track)
    )
  end

  test "concept with two pre-reqs is unlocked when all pre-reqs complete" do
    track = create :track
    user_track = create :user_track, track: track

    # Set up concepts

    basics = create :track_concept, slug: 'basics', track: track
    booleans = create :track_concept, slug: 'booleans', track: track
    atoms = create :track_concept, slug: 'atoms', track: track

    # Set up exercises

    lasagna = create :concept_exercise, track: track
    lasagna.taught_concepts << basics

    pacman = create :concept_exercise, track: track
    pacman.taught_concepts << booleans

    logger = create :concept_exercise, track: track
    logger.taught_concepts << atoms
    logger.prerequisites << basics
    logger.prerequisites << booleans

    # Complete pre-req exercises

    create :user_track_learnt_concept, user_track: user_track, concept: basics
    create :user_track_learnt_concept, user_track: user_track, concept: booleans

    assert_equal(
      {
        'basics' => :complete,
        'booleans' => :complete,
        'atoms' => :unlocked
      },
      ::UserTrack::GenerateConceptsStatus.(user_track)
    )
  end
end
