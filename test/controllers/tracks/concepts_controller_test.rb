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
    assert_template "tracks/concepts/index/joined"
  end

  test "index: renders correctly for unjoined" do
    track = create :track

    sign_in!

    get track_concepts_url(track)
    assert_template "tracks/concepts/index/unjoined"
  end

  test "show: renders correctly for external" do
    track = create :track
    concept = create :track_concept, track: track

    get track_concept_url(track, concept)
    assert_template "tracks/concepts/show/external"
  end

  test "show: renders correctly for available" do
    ut = create :user_track
    concept = create :track_concept, track: ut.track

    UserTrack.any_instance.stubs(learnt_concept?: false)
    UserTrack.any_instance.stubs(concept_available?: true)

    sign_in!(ut.user)

    get track_concept_url(ut.track, concept)
    assert_template "tracks/concepts/show/available"
  end

  test "show: renders correctly for learnt" do
    ut = create :user_track
    concept = create :track_concept, track: ut.track

    UserTrack.any_instance.stubs(learnt_concept?: true)
    UserTrack.any_instance.stubs(concept_available?: true)

    sign_in!(ut.user)

    get track_concept_url(ut.track, concept)
    assert_template "tracks/concepts/show/learnt"
  end

  test "show: renders correctly for locked" do
    ut = create :user_track
    concept = create :track_concept, track: ut.track

    UserTrack.any_instance.stubs(learnt_concept?: false)
    UserTrack.any_instance.stubs(concept_available?: false)

    sign_in!(ut.user)

    get track_concept_url(ut.track, concept)
    assert_template "tracks/concepts/show/locked"
  end

  test "start creates solution and redirects" do
    skip
    user = create :user
    track = create :track
    create :user_track, user: user, track: track

    concept = create :track_concept, track: track, slug: "bools"
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
