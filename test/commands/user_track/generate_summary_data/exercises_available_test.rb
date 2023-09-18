require "test_helper"

class UserTrack::GenerateSummaryData::ExercisesUnlockedTest < ActiveSupport::TestCase
  test "exercise_type" do
    track = create :track
    user_track = create(:user_track, track:)
    concept_exercise = create(:concept_exercise, :random_slug, track:)
    practice_exercise = create(:practice_exercise, :random_slug, track:)

    summary = summary_for(user_track)
    assert_equal :concept, summary.exercise_type(concept_exercise)
    assert_equal :practice, summary.exercise_type(practice_exercise)
  end

  test "exercise_position" do
    track = create :track
    user_track = create(:user_track, track:)
    five = create :concept_exercise, :random_slug, track:, position: 5
    seven = create :practice_exercise, :random_slug, track:, position: 7

    summary = summary_for(user_track)
    assert_equal 5, summary.exercise_position(five)
    assert_equal 7, summary.exercise_position(seven)
  end

  test "exercise_unlocked? with tutorial pending" do
    track = create :track
    user_track = create(:user_track, track:)
    hello_world = create(:hello_world_exercise, track:)
    exercise = create(:concept_exercise, :random_slug, track:)

    summary = summary_for(user_track)
    assert summary.exercise_unlocked?(hello_world)
    refute summary.exercise_unlocked?(exercise)

    create :practice_solution, :completed, exercise: hello_world, user: user_track.user
    summary = summary_for(user_track)
    assert summary.exercise_unlocked?(hello_world)
    assert summary.exercise_unlocked?(exercise)
  end

  test "exercise_unlocked? with no prerequisites" do
    track = create :track
    user_track = create(:user_track, track:)
    create :hello_world_solution, :completed, track:, user: user_track.user

    exercise = create(:concept_exercise, :random_slug, track:)
    assert summary_for(user_track).exercise_unlocked?(exercise)
  end

  test "exercise_unlocked? with prerequisites" do
    track = create :track
    exercise = create(:concept_exercise, :random_slug, track:)

    prereq_1 = create :concept, track:, slug: "bools"
    prereq_exercise_1 = create :concept_exercise, slug: 'bools-exercise'
    create(:exercise_taught_concept, exercise: prereq_exercise_1, concept: prereq_1)
    create(:exercise_prerequisite, exercise:, concept: prereq_1)

    prereq_2 = create :concept, track:, slug: "conditionals"
    prereq_exercise_2 = create :concept_exercise, slug: 'conditionals-exercise'
    create(:exercise_taught_concept, exercise: prereq_exercise_2, concept: prereq_2)
    create(:exercise_prerequisite, exercise:, concept: prereq_2)

    user = create :user
    user_track = create(:user_track, track:, user:)
    create :hello_world_solution, :completed, track:, user: user_track.user
    refute user_track.exercise_unlocked?(exercise)

    create :concept_solution, :completed, user:, exercise: prereq_exercise_1
    user_track.reset_summary!
    refute summary_for(user_track).exercise_unlocked?(exercise)

    create :concept_solution, :completed, user:, exercise: prereq_exercise_2
    user_track.reset_summary!
    assert summary_for(user_track).exercise_unlocked?(exercise)
  end

  test "unlocked concepts" do
    track = create :track
    basics = create :concept, track:, slug: "co_basics"
    enums = create :concept, track:, slug: "co_enums"
    strings = create :concept, track:, slug: "co_strings"

    # Nothing teaches recursion
    recursion = create :concept, track:, slug: "co_recursion"

    basics_exercise = create(:concept_exercise, slug: "ex_basics", track:)
    basics_exercise.taught_concepts << basics

    enums_exercise = create(:concept_exercise, slug: "ex_enums", track:)
    enums_exercise.prerequisites << basics
    enums_exercise.taught_concepts << enums

    strings_exercise = create(:concept_exercise, slug: "ex_strings", track:)
    strings_exercise.prerequisites << enums
    strings_exercise.prerequisites << basics
    strings_exercise.taught_concepts << strings

    practice_exercise = create(:practice_exercise, slug: "ex_prac_enums", track:)
    practice_exercise.prerequisites << enums
    practice_exercise.practiced_concepts << enums

    user = create :user
    user_track = create(:user_track, track:, user:)
    create :hello_world_solution, :completed, track:, user: user_track.user

    assert_equal [basics, recursion], user_track.unlocked_concepts
    assert_empty user_track.learnt_concepts
    assert_empty user_track.mastered_concepts
    assert user_track.concept_unlocked?(recursion)
    assert user_track.concept_unlocked?(basics)
    refute user_track.concept_unlocked?(enums)
    refute user_track.concept_unlocked?(strings)

    create(:concept_solution, :completed, exercise: basics_exercise, user:)

    summary = summary_for(user_track)

    assert_equal [basics, enums, recursion], summary.unlocked_concepts
    assert_equal [basics], summary.learnt_concepts
    assert_equal [basics], summary.mastered_concepts
    assert summary.concept_unlocked?(recursion)
    assert summary.concept_unlocked?(basics)
    assert summary.concept_unlocked?(enums)
    refute summary.concept_unlocked?(strings)

    create(:concept_solution, :completed, exercise: enums_exercise, user:)

    summary = summary_for(user_track)

    assert_equal [basics, enums, strings, recursion], summary.unlocked_concepts
    assert_equal [basics, enums], summary.learnt_concepts
    assert_equal [basics], summary.mastered_concepts
    assert summary.concept_unlocked?(recursion)
    assert summary.concept_unlocked?(basics)
    assert summary.concept_unlocked?(enums)
    assert summary.concept_unlocked?(strings)
  end

  test "locked exercises honour practice mode" do
    track = create :track
    exercise = create(:practice_exercise, :random_slug, track:)
    exercise.prerequisites << create(:concept, track:)

    ut = create(:user_track, track:)
    assert_equal :locked, summary_for(ut).exercise_status(exercise)

    ut.update(practice_mode: true)
    assert_equal :available, summary_for(ut).exercise_status(exercise)
  end

  test "unlocked exercises" do
    track = create :track
    concept_exercise_1 = create(:concept_exercise, :random_slug, track:)
    concept_exercise_2 = create(:concept_exercise, :random_slug, track:)
    concept_exercise_3 = create(:concept_exercise, :random_slug, track:)
    concept_exercise_4 = create(:concept_exercise, :random_slug, track:)

    practice_exercise_1 = create(:practice_exercise, :random_slug, track:)
    practice_exercise_2 = create(:practice_exercise, :random_slug, track:)
    practice_exercise_3 = create(:practice_exercise, :random_slug, track:)
    practice_exercise_4 = create(:practice_exercise, :random_slug, track:)

    prereq_1 = create(:concept, track:)
    prereq_2 = create(:concept, track:)

    concept_exercise_5 = create(:concept_exercise, slug: 'pr1-ex', track:)
    concept_exercise_5.taught_concepts << prereq_1
    concept_exercise_6 = create(:concept_exercise, slug: 'pr2-ex', track:)
    concept_exercise_6.taught_concepts << prereq_2

    create(:exercise_prerequisite, exercise: concept_exercise_2, concept: prereq_1)
    create(:exercise_prerequisite, exercise: practice_exercise_2, concept: prereq_1)
    create(:exercise_prerequisite, exercise: concept_exercise_3, concept: prereq_1)
    create(:exercise_prerequisite, exercise: practice_exercise_3, concept: prereq_1)
    create(:exercise_prerequisite, exercise: concept_exercise_3, concept: prereq_2)
    create(:exercise_prerequisite, exercise: practice_exercise_3, concept: prereq_2)
    create(:exercise_prerequisite, exercise: concept_exercise_4, concept: prereq_2)
    create(:exercise_prerequisite, exercise: practice_exercise_4, concept: prereq_2)
    user = create :user
    user_track = create(:user_track, track:, user:)
    hw_solution = create(:hello_world_solution, :completed, track:, user:)
    hello_world = hw_solution.exercise

    summary = summary_for(user_track)

    assert_equal [
      concept_exercise_1, practice_exercise_1, concept_exercise_5, concept_exercise_6, hello_world
    ], summary.unlocked_exercises
    assert_equal [concept_exercise_1, concept_exercise_5, concept_exercise_6], summary.unlocked_concept_exercises
    assert_equal [practice_exercise_1, hello_world], summary.unlocked_practice_exercises

    create :concept_solution, :completed, user:, exercise: concept_exercise_5

    summary = summary_for(user_track)

    assert_equal [
      concept_exercise_1,
      concept_exercise_2,
      practice_exercise_1,
      practice_exercise_2,
      concept_exercise_5,
      concept_exercise_6,
      hello_world
    ], summary.unlocked_exercises

    assert_equal [concept_exercise_1, concept_exercise_2, concept_exercise_5, concept_exercise_6],
      summary.unlocked_concept_exercises
    assert_equal [practice_exercise_1, practice_exercise_2, hello_world], summary.unlocked_practice_exercises

    create :concept_solution, :completed, user:, exercise: concept_exercise_6

    summary = summary_for(user_track)

    assert_equal [
      concept_exercise_1, concept_exercise_2, concept_exercise_3, concept_exercise_4,
      practice_exercise_1, practice_exercise_2, practice_exercise_3, practice_exercise_4,
      concept_exercise_5, concept_exercise_6,
      hello_world
    ], summary.unlocked_exercises

    assert_equal [
      concept_exercise_1, concept_exercise_2, concept_exercise_3, concept_exercise_4,
      concept_exercise_5, concept_exercise_6
    ], summary.unlocked_concept_exercises

    assert_equal [
      practice_exercise_1,
      practice_exercise_2,
      practice_exercise_3,
      practice_exercise_4,
      hello_world
    ], summary.unlocked_practice_exercises
  end

  test "unlocked exercises based on status" do
    track = create :track
    create :concept_exercise, :random_slug, track:, status: :wip
    beta_concept_exercise = create :concept_exercise, :random_slug, track:, status: :beta
    active_concept_exercise = create :concept_exercise, :random_slug, track:, status: :active
    deprecated_concept_exercise = create :concept_exercise, :random_slug, track:, status: :deprecated

    create :practice_exercise, :random_slug, track:, status: :wip
    beta_practice_exercise = create :practice_exercise, :random_slug, track:, status: :beta
    active_practice_exercise = create :practice_exercise, :random_slug, track:, status: :active
    deprecated_practice_exercise = create :practice_exercise, :random_slug, track:, status: :deprecated

    user = create :user
    user_track = create(:user_track, track:, user:)
    hw_solution = create(:hello_world_solution, :completed, track:, user:)
    hello_world = hw_solution.exercise

    summary = summary_for(user_track)

    # Test that the :wip and :deprecated exercises are not shown
    assert_equal [
      beta_concept_exercise, active_concept_exercise, beta_practice_exercise, active_practice_exercise, hello_world
    ], summary.unlocked_exercises
    assert_equal [beta_concept_exercise, active_concept_exercise], summary.unlocked_concept_exercises
    assert_equal [beta_practice_exercise, active_practice_exercise, hello_world], summary.unlocked_practice_exercises

    create :concept_solution, user:, exercise: deprecated_concept_exercise
    create :practice_solution, user:, exercise: deprecated_practice_exercise

    summary = summary_for(user_track)

    # Test that :deprecated exercises are shown if the user has started them but :wip still aren't
    assert_equal [
      beta_concept_exercise,
      active_concept_exercise,
      deprecated_concept_exercise,
      beta_practice_exercise,
      active_practice_exercise,
      deprecated_practice_exercise,
      hello_world
    ], summary.unlocked_exercises
    assert_equal [beta_concept_exercise, active_concept_exercise, deprecated_concept_exercise], summary.unlocked_concept_exercises
    assert_equal [beta_practice_exercise, active_practice_exercise, deprecated_practice_exercise, hello_world],
      summary.unlocked_practice_exercises
  end

  test "maintainers can see WIP exercises" do
    track = create :track
    wip_concept_exercise = create :concept_exercise, :random_slug, track:, status: :wip
    wip_practice_exercise = create :practice_exercise, :random_slug, track:, status: :wip

    user = create :user, roles: [:maintainer], uid: '1232134'
    create :github_team_member, user_id: user.uid, team_name: track.github_team_name
    user_track = create(:user_track, track:, user:)
    hw_solution = create(:hello_world_solution, :completed, track:, user:)
    hello_world = hw_solution.exercise

    summary = summary_for(user_track)

    # Test that the :wip and :deprecated exercises are not shown
    assert_equal [wip_concept_exercise, wip_practice_exercise, hello_world], summary.unlocked_exercises
    assert_equal [wip_concept_exercise], summary.unlocked_concept_exercises
    assert_equal [wip_practice_exercise, hello_world], summary.unlocked_practice_exercises
  end

  test "concept exercises are only available when track has course" do
    track = create :track
    concept_exercise = create(:concept_exercise, :random_slug, track:)
    practice_exercise = create(:practice_exercise, :random_slug, track:)

    user = create :user
    user_track = create(:user_track, track:, user:)
    hw_solution = create(:hello_world_solution, :completed, track:, user:)
    hello_world = hw_solution.exercise

    track.update(course: false)
    summary = summary_for(user_track)
    assert_equal [practice_exercise, hello_world], summary.unlocked_exercises
    assert_empty summary.unlocked_concept_exercises
    assert_equal [practice_exercise, hello_world], summary.unlocked_practice_exercises

    track.update(course: true)
    summary = summary_for(user_track)
    assert_equal [concept_exercise, practice_exercise, hello_world], summary.unlocked_exercises
    assert_equal [concept_exercise], summary.unlocked_concept_exercises
    assert_equal [practice_exercise, hello_world], summary.unlocked_practice_exercises
  end

  private
  def summary_for(user_track)
    user_track = UserTrack.find(user_track.id)
    UserTrack::Summary.new(
      UserTrack::GenerateSummaryData.(user_track.track, user_track)
    )
  end
end
