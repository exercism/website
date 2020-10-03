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

    sign_in!(user)

    get track_concept_url(track, concept)
    assert_template "tracks/concepts/show/joined"
  end

  test "show: renders correctly for unjoined" do
    track = create :track
    concept = create :track_concept, track: track

    sign_in!

    get track_concept_url(track, concept)
    assert_template "tracks/concepts/show/unjoined"
  end
end
