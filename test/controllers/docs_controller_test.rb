require "test_helper"

class DocsControllerTest < ActionDispatch::IntegrationTest
  test "docs shows when logged out" do
    get docs_path
    assert_response :ok
  end

  test "docs shows when logged in" do
    sign_in!
    get docs_path
    assert_response :ok
  end

  test "docs shows when not onboarded" do
    user = create :user, :not_onboarded
    sign_in!(user)
    get docs_path
    assert_response :ok
  end

  test "section shows when logged out" do
    create :document, section: :mentoring, slug: 'APEX'
    get docs_section_path(:mentoring)
    assert_response :ok
  end

  test "section shows when logged in" do
    create :document, section: :mentoring, slug: 'APEX'
    sign_in!
    get docs_section_path(:mentoring)
    assert_response :ok
  end

  test "section shows when not onboarded" do
    create :document, section: :mentoring, slug: 'APEX'
    user = create :user, :not_onboarded
    sign_in!(user)
    get docs_section_path(:mentoring)
    assert_response :ok
  end

  test "section shows 404s for missing document" do
    assert_raises ActiveRecord::RecordNotFound do
      get docs_section_path(:mentoring)
    end
  end

  test "tracks shows when logged out" do
    get docs_tracks_path
    assert_response :ok
  end

  test "tracks shows when logged in" do
    sign_in!
    get docs_tracks_path
    assert_response :ok
  end

  test "tracks shows when not onboarded" do
    user = create :user, :not_onboarded
    sign_in!(user)
    get docs_tracks_path
    assert_response :ok
  end

  test "track index shows when logged out" do
    track = create :track
    get track_docs_path(track)
    assert_response :ok
  end

  test "track index shows when logged in" do
    track = create :track
    sign_in!
    get track_docs_path(track)
    assert_response :ok
  end

  test "track index shows when not onboarded" do
    track = create :track
    user = create :user, :not_onboarded
    sign_in!(user)
    get track_docs_path(track)
    assert_response :ok
  end

  test "track index shows 404s for unknown track" do
    assert_raises ActiveRecord::RecordNotFound do
      get track_docs_path('unknown')
    end
  end

  test "track shows when logged out" do
    doc = create :document, :track
    get track_doc_path(doc.track, doc)
    assert_response :ok
  end

  test "track shows when logged in" do
    doc = create :document, :track
    sign_in!
    get track_doc_path(doc.track, doc)
    assert_response :ok
  end

  test "track shows when not onboarded" do
    doc = create :document, :track
    user = create :user, :not_onboarded
    sign_in!(user)
    get track_doc_path(doc.track, doc)
    assert_response :ok
  end

  test "track shows 404s for missing document" do
    track = create :track
    assert_raises ActiveRecord::RecordNotFound do
      get track_doc_path(track, 'missing')
    end
  end
end
