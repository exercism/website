require "test_helper"

class DocsControllerTest < ActionDispatch::IntegrationTest
  test "docs shows when logged out" do
    get docs_path
    assert_response 200
  end

  test "docs shows when logged in" do
    sign_in!
    get docs_path
    assert_response 200
  end

  test "docs shows when not onboarded" do
    user = create :user, :not_onboarded
    sign_in!(user)
    get docs_path
    assert_response 200
  end

  test "section shows when logged out" do
    create :document, section: :mentoring, slug: 'APEX'
    get docs_section_path(:mentoring)
    assert_response 200
  end

  test "section shows when logged in" do
    create :document, section: :mentoring, slug: 'APEX'
    sign_in!
    get docs_section_path(:mentoring)
    assert_response 200
  end

  test "section shows when not onboarded" do
    create :document, section: :mentoring, slug: 'APEX'
    user = create :user, :not_onboarded
    sign_in!(user)
    get docs_section_path(:mentoring)
    assert_response 200
  end

  test "tracks shows when logged out" do
    get docs_tracks_path
    assert_response 200
  end

  test "tracks shows when logged in" do
    sign_in!
    get docs_tracks_path
    assert_response 200
  end

  test "tracks shows when not onboarded" do
    user = create :user, :not_onboarded
    sign_in!(user)
    get docs_tracks_path
    assert_response 200
  end

  test "track index shows when logged out" do
    track = create :track
    get track_docs_path(track)
    assert_response 200
  end

  test "track index shows when logged in" do
    track = create :track
    sign_in!
    get track_docs_path(track)
    assert_response 200
  end

  test "track index shows when not onboarded" do
    track = create :track
    user = create :user, :not_onboarded
    sign_in!(user)
    get track_docs_path(track)
    assert_response 200
  end
end
