class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  # Rails raises InvalidCrossOriginRequest for any non-XHR GET that responds
  # with a JavaScript content type, whatever its origin. The kernel is loaded by
  # a dynamic import(), which is not an XHR, so serving it trips that check.
  protect_from_forgery except: %i[javascript_browser_test_runner_worker test_runner_artifact]

  before_action :cache_public_action!, only: %i[index]

  # Artifacts are cached for a year, at the edge and in every browser, so any
  # header on them is frozen at first fetch. The page-level ones are wrong on
  # a worker script anyway: the kernel worker takes its CSP from *this*
  # response, so a stale policy here means every kernel reports violations
  # until its uuid changes, however the page's policy moves on. A worker with
  # no policy of its own is governed by the page that created it, which is
  # the one that matters. The Link preloads, body class and Vary are page
  # concerns too, and Vary just fragments the cache.
  skip_after_action :set_csp_header, :set_link_header, :set_body_class_header, :set_vary_header,
    only: %i[test_runner_artifact frontend_catalog]

  # Guessed content types break the editor: WebAssembly.instantiateStreaming
  # rejects anything that is not application/wasm, and a module worker needs a
  # JavaScript type. S3's own metadata is not trusted for the same reason.
  ARTIFACT_CONTENT_TYPES = {
    ".wasm" => "application/wasm",
    ".mjs" => "text/javascript",
    ".js" => "text/javascript",
    ".json" => "application/json",
    ".tar" => "application/x-tar"
  }.freeze

  # Only the shapes we publish. S3 keys are literal so dot segments are not
  # traversal, but there is no reason to pass them on either.
  SAFE_ARTIFACT_PATH = %r{\A[a-zA-Z0-9][a-zA-Z0-9._/-]*\z}
  private_constant :ARTIFACT_CONTENT_TYPES, :SAFE_ARTIFACT_PATH

  def index
    return redirect_to dashboard_path if user_signed_in?

    @num_tracks = Track.num_active
    return unless stale?(etag: [@num_tracks, 1])

    @tracks = Track.active.order(num_students: :desc).limit(12).to_a

    @showcase_exercises = [
      { slug: "allergies", num_tracks: 40 },
      { slug: "queen-attack", num_tracks: 60 },
      { slug: "zebra-puzzle", num_tracks: 70 }
    ]
  end

  def health_check
    user = User.find(User::SYSTEM_USER_ID)

    render json: {
      ruok: true,
      sanity_data: {
        user: user.handle
      }
    }
  end

  def supporter_gobridge
    @blog_posts = BlogPost.where(slug: 'exercism-is-the-official-go-mentoring-platform')
  end

  def ihid
    expires_in 10, public: true unless user_signed_in?
    stale = stale?(etag: "foo")
    Rails.logger.unknown "|| iHiD: User: #{current_user&.id}, Stale: #{stale}, Time: #{Time.current.to_f}, IP: #{request.remote_ip}, Params: #{params.permit!.to_h}" # rubocop:disable Layout/LineLength
    render json: { "Hello": "iHiD" } if stale
  end

  def frontend_catalog
    locale = params[:catalog_locale]
    return head :not_found unless I18n.available_locales.include?(locale&.to_sym)

    json = File.binread(TranslationRepo.frontend_catalog_path(locale))
    return head :not_found unless TranslationRepo.catalog_hash(json) == params[:hash]

    scope = user_signed_in? || cookies.signed[:_exercism_user_id].present? ? "private" : "public"
    response.set_header("Cache-Control", "#{scope}, max-age=31536000, immutable")
    send_data json, type: "application/json", disposition: :inline
  rescue Errno::ENOENT
    head :not_found
  end

  # Client-side test runner artifacts: the wasm kernel, and the per-language
  # sysroots and runner tarballs the editor boots to run tests in the browser.
  #
  # These have to come from our own origin. `new Worker()` refuses a
  # cross-origin script URL - no header lifts that - and the editor runs the
  # kernel in a worker, so serving them from the assets host is not an option.
  # Nothing else can put them on this origin either: exercism.org resolves to
  # the ALB, and rerouting a path at the edge needs Cloudflare features we do
  # not have. So the app reads them from S3 and serves the bytes itself.
  #
  # That is cheaper than it sounds. Everything here is immutable and cached by
  # Cloudflare, including for logged-in users, so a given artifact is read from
  # here roughly once per edge location per release.
  def test_runner_artifact
    return head :not_found unless test_runners_bucket

    path = params[:path].to_s
    return head :not_found unless SAFE_ARTIFACT_PATH.match?(path)
    return head :not_found if path.include?("..")

    key = "test-runners/#{path}"

    object = Exercism.s3_client.get_object(bucket: test_runners_bucket, key:)

    # latest.json is the only mutable object - it is how a language is pointed
    # at a new build - so it gets a short life. Everything it points at lives
    # under a uuid and never changes.
    cache_control = key.end_with?("latest.json") ? "public, max-age=60" : "public, max-age=31536000, immutable"
    response.set_header("Cache-Control", cache_control)

    # The kernel runs in a worker spawned by a cross-origin isolated page, and a
    # worker script has to declare a policy compatible with its owner's - this
    # is required even though the script is same-origin. Without it the worker
    # refuses to start, and reports nothing more useful than "error".
    response.set_header("Cross-Origin-Embedder-Policy", "require-corp")
    response.set_header("Cross-Origin-Resource-Policy", "same-origin")

    send_data object.body.read, type: artifact_content_type(key), disposition: :inline
  rescue Aws::S3::Errors::ServiceError
    # A missing key reads as AccessDenied rather than NoSuchKey, because the app
    # can get objects but not list the bucket. Either way there is nothing to
    # serve, and the editor treats that as "no client-side runner for this
    # track" and runs the tests on the server instead.
    head :not_found
  end

  def javascript_browser_test_runner_worker
    base_path = Rails.root.join('node_modules', '@exercism', 'javascript-browser-test-runner')
    # extract version from the installed package.json file
    pkg_path = base_path.join('package.json')
    version = File.exist?(pkg_path) ? JSON.parse(File.read(pkg_path))['version'] : 'dev'

    return unless stale?(etag: version)

    file_path = base_path.join('output', 'javascript-browser-test-runner-worker.mjs')

    render file: file_path, content_type: 'application/javascript'
  end

  private
  def artifact_content_type(key) = ARTIFACT_CONTENT_TYPES.fetch(File.extname(key), "application/octet-stream")

  # Absent until the bucket is configured for the environment, which is how dev
  # and test get a clean 404 rather than an error.
  def test_runners_bucket
    return nil unless Exercism.config.respond_to?(:aws_test_runners_bucket)

    Exercism.config.aws_test_runners_bucket
  end
end
