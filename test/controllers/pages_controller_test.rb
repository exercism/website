require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "index shows" do
    get "/"
    assert_response :ok
  end

  test "index shows its showcase exercises in another locale" do
    showcase = { allergies: { title: "Allergiák", blurb: "Blurb" } }
    catalog = { pages: { index: { exercises_section: { showcase: } } } }

    with_published_translations(hu: { backend: catalog }) do
      get "/hu"
    end

    assert_response :ok
    assert_includes response.body, "Allergiák"
  end

  test "index redirects if logged n" do
    sign_in!
    get "/"
    assert_redirected_to "http://test.exercism.org/dashboard"
  end

  # A key that is not in the bucket is how a track without a client-side runner
  # looks. It must answer rather than raise: the editor asks for a manifest on
  # every page load, and an unhandled error fails any system test that opens
  # the editor.
  test "test runner artifacts 404 when the object is missing" do
    get "/test-runners/missing/latest.json"
    assert_response :not_found
  end

  # The kernel worker takes its CSP from the artifact response, and that
  # response is cached for a year, so the page-only headers must not be on it.
  test "test runner artifacts carry no page headers" do
    upload_test_runner_artifact("kernel/abc/kernel.js", "// kernel")

    get "/test-runners/kernel/abc/kernel.js"

    assert_response :ok
    assert_equal "text/javascript", response.media_type
    assert_equal %w[immutable max-age=31536000 no-transform public], response.headers["Cache-Control"].split(", ").sort
    assert_nil response.headers["Content-Encoding"]
    assert_nil response.headers["Content-Security-Policy-Report-Only"]
    assert_nil response.headers["Link"]
    assert_nil response.headers["Exercism-Body-Class"]
    refute_includes response.headers["Vary"].to_s, "Turbo-Frame"
  end

  # Artifacts are stored brotli-encoded. The header has to reach the browser,
  # or it gets the compressed bytes as the file.
  test "test runner artifacts keep their content encoding" do
    upload_test_runner_artifact("sysroot/cpp/19.0.0/1/sysroot.tar", "brotli bytes", content_encoding: "br")

    get "/test-runners/sysroot/cpp/19.0.0/1/sysroot.tar"

    assert_response :ok
    assert_equal "br", response.headers["Content-Encoding"]
    assert_equal "application/x-tar", response.media_type
    assert_equal "brotli bytes", response.body
  end

  test "latest.json gets a short life" do
    upload_test_runner_artifact("cpp/latest.json", "{}")

    get "/test-runners/cpp/latest.json"

    assert_response :ok
    assert_equal %w[max-age=60 no-transform public], response.headers["Cache-Control"].split(", ").sort
  end

  test "health_check works" do
    user = create :user, :system

    get "/health-check"

    assert_response :ok
    expected = {
      ruok: true,
      sanity_data: {
        user: user.handle
      }
    }
    assert_equal expected.to_json, response.body
  end

  test "frontend catalog is publicly cacheable only when nobody is signed in" do
    with_published_translations(hu: { frontend: { ns: { a: "b" } } }) do
      url = TranslationRepo.frontend_catalog_url(:hu)

      get url
      assert_response :ok
      assert_equal %w[immutable max-age=31536000 public], response.headers["Cache-Control"].split(", ").sort
      assert_nil response.headers["Set-Cookie"]

      sign_in!
      get url
      assert_response :ok
      assert_equal %w[immutable max-age=31536000 private], response.headers["Cache-Control"].split(", ").sort
    end
  end

  test "frontend catalog 404s for a stale hash" do
    with_published_translations(hu: { frontend: { ns: { a: "b" } } }) do
      get "/i18n/hu/frontend-0123456789ab.json"
      assert_response :not_found
    end
  end

  private
  def upload_test_runner_artifact(path, body, content_encoding: nil)
    Exercism.s3_client.put_object(
      bucket: Exercism.config.aws_test_runners_bucket,
      key: "test-runners/#{path}",
      body:,
      content_encoding:
    )
  end
end
