require "test_helper"

class UserTrack::GenerateSummaryData::ConceptTest < ActiveSupport::TestCase
  test "with multi-type accessing" do
    track = create :track
    concept = create(:concept, track:)
    ut = create(:user_track, track:)

    summary = UserTrack::Summary.new(UserTrack::GenerateSummaryData.(track, ut))

    # Test we can access by object or slug
    assert_equal concept.slug, summary.concept(concept).slug
    assert_equal concept.slug, summary.concept(concept.slug).slug
  end

  test "with no exercises" do
    track = create :track
    concept = create(:concept, track:)
    ut = create(:user_track, track:)

    summary = UserTrack::Summary.new(UserTrack::GenerateSummaryData.(track, ut))

    expected = UserTrack::Summary::ConceptSummary.new(
      id: concept.id,
      slug: concept.slug,
      num_concept_exercises: 0,
      num_practice_exercises: 0,
      num_completed_concept_exercises: 0,
      num_completed_practice_exercises: 0,
      unlocked: true,
      learnt: false
    )

    assert_equal expected, summary.concept(concept.slug)
  end

  test "unstarted" do
    track = create :track
    concept = create :concept, track:, slug: "strings"
    ut = create(:user_track, track:)
    create :hello_world_solution, :completed, track:, user: ut.user

    ce_1 = create(:concept_exercise, :random_slug, track:)
    ce_1.taught_concepts << concept
    ce_2 = create(:concept_exercise, :random_slug, track:)
    ce_2.taught_concepts << create(:concept, track:)

    pe_1 = create(:practice_exercise, :random_slug, track:)
    pe_1.practiced_concepts << concept
    pe_2 = create(:practice_exercise, :random_slug, track:)
    pe_2.practiced_concepts << concept
    pe_3 = create(:practice_exercise, :random_slug, track:)
    pe_3.practiced_concepts << create(:concept, track:)

    summary = UserTrack::Summary.new(UserTrack::GenerateSummaryData.(track, ut))

    expected = UserTrack::Summary::ConceptSummary.new(
      id: concept.id,
      slug: concept.slug,
      num_concept_exercises: 1,
      num_practice_exercises: 2,
      num_completed_concept_exercises: 0,
      num_completed_practice_exercises: 0,
      unlocked: true,
      learnt: false
    )
    assert_equal expected, summary.concept(concept.slug)
  end

  test "completed" do
    track = create :track
    concept = create(:concept, track:)
    user = create :user
    ut = create(:user_track, track:, user:)

    ce_1 = create(:concept_exercise, :random_slug, track:)
    ce_1.taught_concepts << concept
    create :concept_solution, user:, exercise: ce_1, completed_at: nil

    ce_2 = create(:concept_exercise, :random_slug, track:)
    ce_2.taught_concepts << concept
    create :concept_solution, user:, exercise: ce_2, completed_at: Time.current

    pe_1 = create(:practice_exercise, :random_slug, track:)
    pe_1.practiced_concepts << concept
    create :practice_solution, user:, exercise: pe_1, completed_at: nil

    pe_2 = create(:practice_exercise, :random_slug, track:)
    pe_2.practiced_concepts << concept
    create :practice_solution, user:, exercise: pe_2, completed_at: Time.current

    pe_3 = create(:practice_exercise, :random_slug, track:)
    pe_3.practiced_concepts << concept
    create :practice_solution, user:, exercise: pe_3, completed_at: Time.current

    summary = UserTrack::Summary.new(UserTrack::GenerateSummaryData.(track, ut))

    expected = UserTrack::Summary::ConceptSummary.new(
      id: concept.id,
      slug: concept.slug,
      num_concept_exercises: 2,
      num_practice_exercises: 3,
      num_completed_concept_exercises: 1,
      num_completed_practice_exercises: 2,
      unlocked: true,
      learnt: true
    )
    assert_equal expected, summary.concept(concept.slug)
  end

  test "external user_track" do
    track = create :track
    concept = create(:concept, track:)

    ce_1 = create(:concept_exercise, :random_slug, track:)
    ce_1.taught_concepts << concept
    ce_2 = create(:concept_exercise, :random_slug, track:)
    ce_2.taught_concepts << create(:concept, track:)

    pe_1 = create(:practice_exercise, :random_slug, track:)
    pe_1.practiced_concepts << concept
    pe_2 = create(:practice_exercise, :random_slug, track:)
    pe_2.practiced_concepts << concept
    pe_3 = create(:practice_exercise, :random_slug, track:)
    pe_3.practiced_concepts << create(:concept, track:)

    summary = UserTrack::Summary.new(UserTrack::GenerateSummaryData.(track, UserTrack::External.new(track)))

    expected = UserTrack::Summary::ConceptSummary.new(
      id: concept.id,
      slug: concept.slug,
      num_concept_exercises: 1,
      num_practice_exercises: 2,
      num_completed_concept_exercises: 0,
      num_completed_practice_exercises: 0,
      unlocked: true,
      learnt: false
    )
    assert_equal expected, summary.concept(concept.slug)
  end
end
