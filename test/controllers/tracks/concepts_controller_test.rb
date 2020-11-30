require "test_helper"

class Tracks::ConceptsControllerTest < ActionDispatch::IntegrationTest
  test "index: renders correctly for external" do
    # TODO: Unskip when devise is added
    skip

    track = create :track

    get track_concepts_url(track)
    assert_template "tracks/concepts/index/external"
  end

  test "index: renders correctly for joined" do
    user = create :user
    track = create :track
    create :user_track, user: user, track: track

    sign_in!(user)

    get track_concepts_url(track)
    assert_template "tracks/concepts/index"
  end

  test "index: renders correctly for unjoined" do
    user = create :user
    track = create :track

    sign_in!(user)

    get track_concepts_url(track)
    assert_template "tracks/concepts/index"
  end

  test "show: renders correctly for external" do
    concept = create :track_concept, :with_git_data
    track = concept.track

    get track_concept_url(track, concept)
    assert_template "tracks/concepts/show"
  end

  test "show: renders correctly for available" do
    concept = create :track_concept, :with_git_data
    user = create :user
    create :user_track, track: concept.track, user: user

    UserTrack.any_instance.stubs(concept_learnt?: false)
    UserTrack.any_instance.stubs(concept_available?: true)

    sign_in!(user)

    get track_concept_url(concept.track, concept)
    assert_template "tracks/concepts/show"
  end

  test "show: renders correctly for learnt" do
    concept = create :track_concept, :with_git_data
    user = create :user
    ut = create :user_track, track: concept.track, user: user

    UserTrack.any_instance.stubs(concept_learnt?: true)
    UserTrack.any_instance.stubs(concept_available?: true)

    sign_in!(user)

    get track_concept_url(ut.track, concept)
    assert_template "tracks/concepts/show"
  end

  test "show: renders correctly for locked" do
    concept = create :track_concept, :with_git_data
    user = create :user
    ut = create :user_track, track: concept.track, user: user

    UserTrack.any_instance.stubs(concept_learnt?: false)
    UserTrack.any_instance.stubs(concept_available?: false)

    sign_in!(user)

    get track_concept_url(ut.track, concept)
    assert_template "tracks/concepts/show"
  end

  test "start creates solution and redirects" do
    skip
    user = create :user
    concept = create :track_concept, :with_git_data
    create :user_track, track: concept.track

    ce = create(:concept_exercise, track: track).tap { |e| e.taught_concepts << concept }

    sign_in!(user)

    patch start_track_concept_url(track, concept)

    solution = Solution.last
    assert solution
    assert ce, solution.exercise
    assert user, solution.user

    assert_redirected_to edit_solution_path(solution.uuid)
  end
end
