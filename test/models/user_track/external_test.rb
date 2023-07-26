require "test_helper"

class UserTrack::ExternalTest < ActiveSupport::TestCase
  test "hard-coded methods" do
    ut = UserTrack::External.new(mock)
    assert ut.external?
    assert_empty ut.learnt_concepts
    refute ut.maintainer?

    assert ut.exercise_unlocked?(nil)
    refute ut.exercise_completed?(nil)
    assert_equal :external, ut.exercise_status(nil)

    assert_equal 0, ut.num_completed_exercises
    assert_empty ut.unlocked_exercise_ids

    refute ut.concept_unlocked?(mock)
    refute ut.concept_learnt?(mock)
    refute ut.concept_mastered?(mock)
    assert_equal 0, ut.num_completed_exercises_for_concept(mock)

    assert_empty ut.unlocked_concept_ids
    assert_equal 0, ut.num_concepts_learnt
    assert_equal 0, ut.num_concepts_mastered
  end

  test "num_exercises" do
    track = create :track

    create :concept_exercise, :random_slug, track:, status: :wip
    create :concept_exercise, :random_slug, track:, status: :beta
    create :concept_exercise, :random_slug, track:, status: :active
    create :concept_exercise, :random_slug, track:, status: :deprecated

    create :practice_exercise, :random_slug, track:, status: :wip
    create :practice_exercise, :random_slug, track:, status: :beta
    create :practice_exercise, :random_slug, track:, status: :active
    create :practice_exercise, :random_slug, track:, status: :deprecated

    ut = UserTrack::External.new(track)
    assert_equal 4, ut.num_exercises
  end

  test "num_concepts" do
    track = create :track

    concept_1 = create(:concept, track:)
    concept_2 = create(:concept, track:)

    ce_1 = create(:concept_exercise, :random_slug, track:)
    ce_1.taught_concepts << concept_1

    ce_2 = create(:concept_exercise, :random_slug, track:)
    ce_2.taught_concepts << concept_2

    ce_3 = create(:concept_exercise, :random_slug, track:)
    ce_3.taught_concepts << concept_1
    ce_3.taught_concepts << concept_2

    ut = UserTrack::External.new(track.reload)
    assert_equal 2, ut.num_concepts
  end

  test "num_exercises_for_concept" do
    track = create :track
    concept_1 = create(:concept, track:)
    concept_2 = create(:concept, track:)

    ce_1 = create(:concept_exercise, :random_slug, track:)
    ce_1.taught_concepts << concept_1

    ce_2 = create(:concept_exercise, :random_slug, track:)
    ce_2.prerequisites << concept_1 # This should not be counted
    ce_1.taught_concepts << concept_2

    pe_1 = create(:practice_exercise, :random_slug, track:)
    pe_1.prerequisites << concept_1
    pe_1.prerequisites << concept_2

    pe_2 = create(:practice_exercise, :random_slug, track:)
    pe_2.prerequisites << concept_1

    ut = UserTrack::External.new(track)
    assert_equal 3, ut.num_exercises_for_concept(concept_1)
    assert_equal 2, ut.num_exercises_for_concept(concept_2)
  end

  test "exercises" do
    track = create :track

    create :concept_exercise, :random_slug, track:, status: :wip
    beta_concept_exercise = create :concept_exercise, :random_slug, track:, status: :beta
    active_concept_exercise = create :concept_exercise, :random_slug, track:, status: :active
    create :concept_exercise, :random_slug, track:, status: :deprecated

    create :practice_exercise, :random_slug, track:, status: :wip
    beta_practice_exercise = create :practice_exercise, :random_slug, track:, status: :beta
    active_practice_exercise = create :practice_exercise, :random_slug, track:, status: :active
    create :practice_exercise, :random_slug, track:, status: :deprecated

    # wip and deprecated exercises are not included
    track.update(course: true)
    user_track = UserTrack::External.new(track)
    assert_equal [
      beta_concept_exercise,
      active_concept_exercise,
      beta_practice_exercise,
      active_practice_exercise
    ].map(&:slug).sort, user_track.exercises.map(&:slug).sort

    # concept exercises are excluded when track does not have course
    track.update(course: false)
    user_track = UserTrack::External.new(track)
    assert_equal [
      beta_practice_exercise,
      active_practice_exercise
    ].map(&:slug).sort, user_track.exercises.map(&:slug).sort
  end

  test "concept_exercises" do
    track = create :track

    create :concept_exercise, :random_slug, track:, status: :wip
    beta_concept_exercise = create :concept_exercise, :random_slug, track:, status: :beta
    active_concept_exercise = create :concept_exercise, :random_slug, track:, status: :active
    create :concept_exercise, :random_slug, track:, status: :deprecated

    # Sanity check: practice exercise should not be included
    create(:practice_exercise, :random_slug, track:)

    # wip and deprecated exercises are not included
    track.update(course: true)
    user_track = UserTrack::External.new(track)
    assert_equal [
      beta_concept_exercise,
      active_concept_exercise
    ].map(&:slug).sort, user_track.concept_exercises.map(&:slug).sort

    # concept exercises are excluded when track does not have course
    track.update(course: false)
    user_track = UserTrack::External.new(track)
    assert_empty user_track.concept_exercises
  end

  test "practice_exercises" do
    track = create :track

    create :practice_exercise, :random_slug, track:, status: :wip
    beta_practice_exercise = create :practice_exercise, :random_slug, track:, status: :beta
    active_practice_exercise = create :practice_exercise, :random_slug, track:, status: :active
    create :practice_exercise, :random_slug, track:, status: :deprecated

    # Sanity check: concept exercise should not be included
    create(:concept_exercise, :random_slug, track:)

    # wip and deprecated exercises are not included
    track.update(course: true)
    user_track = UserTrack::External.new(track)
    assert_equal [
      beta_practice_exercise,
      active_practice_exercise
    ].map(&:slug).sort, user_track.practice_exercises.map(&:slug).sort

    # practice exercises are included when track does not have course
    track.update(course: false)
    user_track = UserTrack::External.new(track)
    assert_equal [
      beta_practice_exercise,
      active_practice_exercise
    ].map(&:slug).sort, user_track.practice_exercises.map(&:slug).sort
  end

  test "concept_exercises_for_concept" do
    track = create :track
    user_track = UserTrack::External.new(track)

    c_1 = create :concept, track:, slug: "strings"
    c_2 = create :concept, track:, slug: "numbers"

    ce_1 = create(:concept_exercise, :random_slug, track:)
    ce_1.taught_concepts << c_1

    ce_2 = create(:concept_exercise, :random_slug, track:)
    ce_2.taught_concepts << c_1
    ce_2.prerequisites << c_2

    # Sanity check: don't include concept exercise with different concept
    ce_3 = create(:concept_exercise, :random_slug, track:)
    ce_3.taught_concepts << c_2

    # Sanity check: don't include concept exercise exercise that has concept as prerequisite
    ce_4 = create(:concept_exercise, :random_slug, track:)
    ce_4.prerequisites << c_1

    # Sanity check: don't include concept exercise without taught concept
    ce_5 = create(:concept_exercise, :random_slug, track:)
    ce_5.taught_concepts = []

    # Sanity check: don't include practice exercises
    create(:practice_exercise, :random_slug, track:)
    pe_1 = create(:practice_exercise, :random_slug, track:)
    pe_1.practiced_concepts << c_1

    expected = [ce_1, ce_2].map(&:slug).sort
    assert_equal expected, user_track.concept_exercises_for_concept(c_1).map(&:slug).sort
  end

  test "practice_exercises_for_concept" do
    track = create :track
    user_track = UserTrack::External.new(track)

    c_1 = create :concept, track:, slug: "strings"
    c_2 = create :concept, track:, slug: "numbers"

    pe_1 = create(:practice_exercise, :random_slug, track:)
    pe_1.practiced_concepts << c_1

    pe_2 = create(:practice_exercise, :random_slug, track:)
    pe_2.practiced_concepts << c_1
    pe_2.practiced_concepts << c_2

    # Sanity check: don't include practice exercise with different concept
    pe_3 = create(:practice_exercise, :random_slug, track:)
    pe_3.practiced_concepts << c_2

    # Sanity check: don't include practice exercise that has concept as prerequisite
    pe_4 = create(:practice_exercise, :random_slug, track:)
    pe_4.prerequisites << c_1

    # Sanity check: don't include practice exercise without practiced concept
    pe_5 = create(:practice_exercise, :random_slug, track:)
    pe_5.practiced_concepts = []

    # Sanity check: don't include concept exercises
    create(:concept_exercise, :random_slug, track:)
    ce_1 = create(:concept_exercise, :random_slug, track:)
    ce_1.taught_concepts << c_1

    expected = [pe_1, pe_2].map(&:slug).sort
    assert_equal expected, user_track.practice_exercises_for_concept(c_1).map(&:slug).sort
  end

  test "course?" do
    track = create :track
    ut = UserTrack::External.new(track)

    track.update(course: false)
    refute ut.course?

    track.update(course: true)
    assert ut.course?
  end
end
