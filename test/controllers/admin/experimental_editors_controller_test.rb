require "test_helper"

class Admin::ExperimentalEditorsControllerTest < ActionDispatch::IntegrationTest
  test "index - redirects non maintainers" do
    create :track, slug: "jq"
    sign_in!(create(:user))

    get admin_experimental_editors_path
    assert_redirected_to root_path
  end

  test "index - shows for maintainer" do
    create :track, slug: "jq"
    sign_in!(create(:user, :maintainer))

    get admin_experimental_editors_path
    assert_response :ok
  end

  test "show - is cross-origin isolated" do
    track = create :track, slug: "jq"
    create(:practice_exercise, track:, slug: "hello-world")
    sign_in!(create(:user, :maintainer))

    get admin_experimental_editor_path("jq", "hello-world")

    # The kernel needs SharedArrayBuffer, which needs both of these headers.
    # See CrossOriginIsolation.
    assert_equal "same-origin", response.headers["Cross-Origin-Opener-Policy"]
    assert_equal "require-corp", response.headers["Cross-Origin-Embedder-Policy"]
  end

  test "show - refuses a track without a client-side test runner" do
    track = create :track, slug: "ruby"
    create(:practice_exercise, track:, slug: "hello-world")
    sign_in!(create(:user, :maintainer))

    assert_raises ActiveRecord::RecordNotFound do
      get admin_experimental_editor_path("ruby", "hello-world")
    end
  end

  test "show - joins the track so a solution can be created" do
    track = create :track, slug: "jq"
    create(:practice_exercise, track:, slug: "hello-world")
    user = create :user, :maintainer
    sign_in!(user)

    get admin_experimental_editor_path("jq", "hello-world")

    assert_response :ok
    assert UserTrack.exists?(user:, track:)
  end
end
