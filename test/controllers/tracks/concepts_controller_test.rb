require "test_helper"

class Tracks::ConceptsControllerTest < ActionDispatch::IntegrationTest
  test "index: redirects if in practice mode" do
    track = create :track, course: true
    user = create :user
    create :user_track, track:, user:, practice_mode: true
    sign_in!(user)

    get track_concepts_url(track)
    assert_redirected_to track_path(track)
  end

  test "index: redirects if track does not have course" do
    track = create :track, course: false
    user = create :user
    create :user_track, track:, user:, practice_mode: true
    sign_in!(user)

    get track_concepts_url(track)
    assert_redirected_to track_path(track)
  end

  test "index: renders correctly for external" do
    track = create :track, course: true

    get track_concepts_url(track)
    assert_template "tracks/concepts/index"
  end

  test "index: renders correctly for joined" do
    user = create :user
    track = create :track, course: true
    create(:user_track, user:, track:)

    sign_in!(user)

    get track_concepts_url(track)
    assert_template "tracks/concepts/index"
  end

  test "index: renders correctly for unjoined" do
    user = create :user
    track = create :track, course: true

    sign_in!(user)

    get track_concepts_url(track)
    assert_template "tracks/concepts/index"
  end

  test "index: renders correctly for inactive track and user is a maintainer" do
    user = create :user, roles: [:maintainer]
    track = create :track, active: false, course: true

    sign_in!(user)

    get track_concepts_url(track)
    assert_template "tracks/concepts/index"
  end

  test "index: 404s silently for inactive track and user is not a maintainer" do
    user = create :user
    track = create :track, active: false, course: true

    sign_in!(user)

    get track_concepts_url(track)

    assert_rendered_404
  end

  test "show: 404s silently for missing track" do
    get track_concept_url('foobar', 'foobar')

    assert_rendered_404
  end

  test "show: 404s silently for missing concept" do
    get track_concept_url(create(:track), 'foobar')

    assert_rendered_404
  end

  test "show: renders correctly for inactive track and user is a maintainer" do
    concept = create :concept, :with_git_data
    concept.track.update!(active: false)
    user = create :user, roles: [:maintainer]
    ut = create(:user_track, track: concept.track, user:)

    sign_in!(user)

    get track_concept_url(ut.track, concept)
    assert_template "tracks/concepts/show"
  end

  test "show: 404s silently for inactive track and user is not a maintainer" do
    concept = create :concept, :with_git_data
    concept.track.update!(active: false)
    user = create :user
    ut = create(:user_track, track: concept.track, user:)

    sign_in!(user)

    get track_concept_url(ut.track, concept)

    assert_rendered_404
  end

  test "show: renders correctly for external" do
    concept = create :concept, :with_git_data
    track = concept.track

    get track_concept_url(track, concept)
    assert_template "tracks/concepts/show"
  end

  test "show: renders correctly for available" do
    concept = create :concept, :with_git_data
    user = create :user
    create(:user_track, track: concept.track, user:)

    # TODO: Remove if not uncommented at launch
    # UserTrack.any_instance.stubs(concept_learnt?: false)
    # UserTrack.any_instance.stubs(concept_unlocked?: true)

    sign_in!(user)

    get track_concept_url(concept.track, concept)
    assert_template "tracks/concepts/show"
  end

  test "show: renders correctly for learnt" do
    concept = create :concept, :with_git_data
    user = create :user
    ut = create(:user_track, track: concept.track, user:)

    # TODO: Remove if not uncommented at launch
    # UserTrack.any_instance.stubs(concept_learnt?: true)
    # UserTrack.any_instance.stubs(concept_unlocked?: true)

    sign_in!(user)

    get track_concept_url(ut.track, concept)
    assert_template "tracks/concepts/show"
  end

  test "show: renders correctly for locked" do
    concept = create :concept, :with_git_data
    user = create :user
    ut = create(:user_track, track: concept.track, user:)

    # TODO: Remove if not uncommented at launch
    # UserTrack.any_instance.stubs(concept_learnt?: false)
    # UserTrack.any_instance.stubs(concept_unlocked?: false)

    sign_in!(user)

    get track_concept_url(ut.track, concept)
    assert_template "tracks/concepts/show"
  end

  test "start creates solution and redirects" do
    skip
    user = create :user
    concept = create :concept, :with_git_data
    create :user_track, track: concept.track

    ce = create(:concept_exercise, track:).tap { |e| e.taught_concepts << concept }

    sign_in!(user)

    patch start_track_concept_url(track, concept)

    solution = Solution.last
    assert solution
    assert ce, solution.exercise
    assert user, solution.user

    assert_redirected_to edit_solution_path(solution.uuid)
  end

  test "show: shows about for logged out" do
    concept = create :concept, :with_git_data

    get track_concept_url(concept.track, concept)

    assert_includes response.body, Markdown::Parse.(concept.about)
    refute_includes response.body, Markdown::Parse.(concept.introduction)
  end

  test "show: shows about for external" do
    concept = create :concept, :with_git_data

    sign_in!
    get track_concept_url(concept.track, concept)

    assert_includes response.body, Markdown::Parse.(concept.about)
    refute_includes response.body, Markdown::Parse.(concept.introduction)
  end

  test "show: shows intro for unlearnt" do
    concept = create :concept, :with_git_data
    user = create :user
    create :user_track, user:, track: concept.track

    sign_in!(user)
    get track_concept_url(concept.track, concept)

    assert_includes response.body, Markdown::Parse.(concept.introduction)
    refute_includes response.body, Markdown::Parse.(concept.about)
  end

  test "show: shows about for learnt" do
    concept = create :concept, :with_git_data
    user = create :user
    create :user_track, user:, track: concept.track

    UserTrack.any_instance.stubs(concept_learnt?: true)

    sign_in!(user)
    get track_concept_url(concept.track, concept)

    assert_includes response.body, Markdown::Parse.(concept.about)
    refute_includes response.body, Markdown::Parse.(concept.introduction)
  end
end
