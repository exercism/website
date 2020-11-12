require "test_helper"

class UserTrack::GenerateSummary::ConceptTest < ActiveSupport::TestCase
  test "with multi-type accessing" do
    track = create :track
    concept = create :track_concept, track: track
    ut = create :user_track, track: track

    summary = UserTrack::GenerateSummary.(track, ut)

    # Test we can access by object or slug
    assert_equal concept.slug, summary.concept(concept).slug
    assert_equal concept.slug, summary.concept(concept.slug).slug
  end

  test "with no exercises" do
    track = create :track
    concept = create :track_concept, track: track
    ut = create :user_track, track: track

    summary = UserTrack::GenerateSummary.(track, ut)

    expected = UserTrack::GenerateSummary::ConceptSummary.new(
      id: concept.id,
      slug: concept.slug,
      num_concept_exercises: 0,
      num_practice_exercises: 0,
      num_completed_concept_exercises: 0,
      num_completed_practice_exercises: 0,
      available: true
    )

    assert_equal expected, summary.concept(concept.slug)
  end

  test "unstarted" do
    track = create :track
    concept = create :track_concept, track: track
    ut = create :user_track, track: track

    ce_1 = create :concept_exercise, :random_slug, track: track
    ce_1.taught_concepts << concept
    ce_2 = create :concept_exercise, :random_slug, track: track
    ce_2.taught_concepts << create(:track_concept, track: track)

    pe_1 = create :practice_exercise, :random_slug, track: track
    pe_1.prerequisites << concept
    pe_2 = create :practice_exercise, :random_slug, track: track
    pe_2.prerequisites << concept
    pe_3 = create :practice_exercise, :random_slug, track: track
    pe_3.prerequisites << create(:track_concept, track: track)

    summary = UserTrack::GenerateSummary.(track, ut)

    expected = UserTrack::GenerateSummary::ConceptSummary.new(
      id: concept.id,
      slug: concept.slug,
      num_concept_exercises: 1,
      num_practice_exercises: 2,
      num_completed_concept_exercises: 0,
      num_completed_practice_exercises: 0,
      available: true
    )
    assert_equal expected, summary.concept(concept.slug)
  end

  test "completed" do
    track = create :track
    concept = create :track_concept, track: track
    user = create :user
    ut = create :user_track, track: track, user: user

    ce_1 = create :concept_exercise, :random_slug, track: track
    ce_1.taught_concepts << concept
    create :concept_solution, user: user, exercise: ce_1, completed_at: nil

    ce_2 = create :concept_exercise, :random_slug, track: track
    ce_2.taught_concepts << concept
    create :concept_solution, user: user, exercise: ce_2, completed_at: Time.current

    pe_1 = create :practice_exercise, :random_slug, track: track
    pe_1.prerequisites << concept
    create :practice_solution, user: user, exercise: pe_1, completed_at: nil

    pe_2 = create :practice_exercise, :random_slug, track: track
    pe_2.prerequisites << concept
    create :practice_solution, user: user, exercise: pe_2, completed_at: Time.current

    pe_3 = create :practice_exercise, :random_slug, track: track
    pe_3.prerequisites << concept
    create :practice_solution, user: user, exercise: pe_3, completed_at: Time.current

    summary = UserTrack::GenerateSummary.(track, ut)

    expected = UserTrack::GenerateSummary::ConceptSummary.new(
      id: concept.id,
      slug: concept.slug,
      num_concept_exercises: 2,
      num_practice_exercises: 3,
      num_completed_concept_exercises: 1,
      num_completed_practice_exercises: 2,
      available: true
    )
    assert_equal expected, summary.concept(concept.slug)
  end

  test "no user_track" do
    track = create :track
    concept = create :track_concept, track: track

    ce_1 = create :concept_exercise, :random_slug, track: track
    ce_1.taught_concepts << concept
    ce_2 = create :concept_exercise, :random_slug, track: track
    ce_2.taught_concepts << create(:track_concept, track: track)

    pe_1 = create :practice_exercise, :random_slug, track: track
    pe_1.prerequisites << concept
    pe_2 = create :practice_exercise, :random_slug, track: track
    pe_2.prerequisites << concept
    pe_3 = create :practice_exercise, :random_slug, track: track
    pe_3.prerequisites << create(:track_concept, track: track)

    summary = UserTrack::GenerateSummary.(track, nil)

    expected = UserTrack::GenerateSummary::ConceptSummary.new(
      id: concept.id,
      slug: concept.slug,
      num_concept_exercises: 1,
      num_practice_exercises: 2,
      num_completed_concept_exercises: 0,
      num_completed_practice_exercises: 0,
      available: false
    )
    assert_equal expected, summary.concept(concept.slug)
  end
end
