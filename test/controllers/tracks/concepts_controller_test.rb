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
    # TODO: Unskip when devise is added
    skip

    track = create :track
    concept = create :track_concept, track: track

    get track_concept_url(track, concept)
    assert_template "tracks/concepts/show/external"
  end

  test "show: renders correctly for joined" do
    user = create :user
    track = create :track
    create :user_track, user: user, track: track
    concept = create :track_concept, track: track
    create(:concept_exercise, track: track).tap { |ce| ce.taught_concepts << concept }

    sign_in!(user)

    get track_concept_url(track, concept)
    assert_template "tracks/concepts/show/joined"
  end

  test "show: renders correctly for unjoined" do
    track = create :track
    concept = create :track_concept, track: track
    create(:concept_exercise, track: track).tap { |ce| ce.taught_concepts << concept }

    sign_in!

    get track_concept_url(track, concept)
    assert_template "tracks/concepts/show/unjoined"
  end

  test "start creates solution and redirects" do
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
