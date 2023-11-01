ENV['RAILS_ENV'] ||= 'test'

require_relative '../config/environment'
require 'rails/test_help'
require 'mocha/minitest'
require 'minitest/pride'
require 'webmock/minitest'
require 'minitest/retry'
require_relative './helpers/turbo_assertions_helper'
require 'generate_js_config'

# We need to write the manifest.json and env.json files as the
# javascript:build rake task that is called below depends on it
GenerateJSConfig.generate!

# We need to build our JS and CSS before running tests
# In CI, this happens through the test:prepare rake task
# but locally when running single tests, we might need this intead
`bundle exec rake css:build` unless File.exist?(Rails.root / '.built-assets' / 'website.css')
`bundle exec rake javascript:build` unless File.exist?(Rails.root / '.built-assets' / 'test.js')

# Handle flakey tests in CI
Minitest::Retry.use!(retry_count: 3) if ENV["EXERCISM_CI"]

# Have Geocoder use a fixed stub value
Geocoder.configure(lookup: :test, ip_lookup: :test)
Geocoder::Lookup::Test.add_stub('127.0.0.1', [{ 'country_code' => 'US' }])

# use a fixed remote IP
Exercism.request_context = { remote_ip: '127.0.0.1' }

# Configure mocha to be safe
Mocha.configure do |c|
  c.stubbing_method_unnecessarily = :prevent
  c.stubbing_non_existent_method = :prevent
  c.stubbing_method_on_nil = :prevent
  c.stubbing_non_public_method = :prevent
end

# Require the support helper files
Dir.foreach(Rails.root / "test" / "support") do |path|
  next if path.starts_with?('.')

  require Rails.root / "test" / "support" / path
end

# This "fixes" reload in Madnate.
# TODO: (Optional) Move this into Mandate
module ActiveRecord
  class Base
    def reload(*args)
      super
      @__mandate_memoized_results = {}

      self
    end
  end
end

class Hash
  def to_obj = JSON.parse(to_json, object_class: OpenStruct)
end

module TestHelpers
  extend ActionView::Helpers::AssetUrlHelper

  def self.git_repo_url(slug)
    "file://#{Rails.root / 'test' / 'repos' / slug.to_s}"
  end

  def self.use_website_copy_test_repo!
    repo_url = TestHelpers.git_repo_url("website-copy")
    Git::WebsiteCopy.new(repo_url:).tap do |repo|
      Git::WebsiteCopy.expects(:new).at_least_once.returns(repo)
    end
  end

  def self.use_blog_test_repo!
    repo_url = TestHelpers.git_repo_url("blog")
    repo = Git::Blog.new(repo_url:)
    Git::Blog.expects(:new).at_least_once.returns(repo)
  end

  def self.use_docs_test_repo!
    repo_url = TestHelpers.git_repo_url("docs")
    repo = Git::Repository.new(repo_url:)
    Git::Repository.expects(:new).at_least_once.returns(repo)
  end

  def self.use_problem_specifications_test_repo!
    repo_url = TestHelpers.git_repo_url("problem-specifications")
    Git::ProblemSpecifications.new(repo_url:).tap do |repo|
      Git::ProblemSpecifications.expects(:new).at_least_once.returns(repo)
    end
  end

  def self.download_dir = Rails.root / 'tmp' / 'downloads'
  def self.download_filepath(filename) = File.join(download_dir, filename)
end

class ActiveSupport::TimeWithZone
  def ==(other)
    to_i == other.to_i
  end
end

if ENV["EXERCISM_CI"]
  WebMock.disable_net_connect!(
    allow: [
      # It would be nice not to need this but Chrome
      # uses lots of ports on localhost for thesystem tests
      "127.0.0.1",
      "chromedriver.storage.googleapis.com",
      "127.0.0.1:#{ENV['AWS_PORT']}",
      "127.0.0.1:#{ENV['OPENSEARCH_PORT']}"
    ]
  )
else
  WebMock.disable_net_connect!(
    allow: [
      # It would be nice not to need this but Chrome
      # uses lots of ports on localhost for thesystem tests
      "127.0.0.1",
      "chromedriver.storage.googleapis.com",
      "localhost:3040", "localhost:9200",
      "aws", "opensearch"
    ]
  )
end

class ActionMailer::TestCase
  def assert_email(email, to, subject, fixture, bulk: false) # rubocop:disable Lint/UnusedMethodArgument
    # Test email can send ok
    assert_emails 1 do
      email.deliver_now
    end

    tld = "org" # bulk ? "io" : "org"
    from = "hello@mail.exercism.#{tld}"

    # Test the body of the sent email contains what we expect it to
    assert_equal [from], email.from
    assert_equal [to], email.to
    assert_equal subject, email.subject
    read_fixture(fixture).each do |text|
      assert_includes email.html_part.body.to_s, text.strip
    end
  end
end

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
  include ActiveJob::TestHelper

  # Run tests in parallel with specified workers
  # parallelize(workers: :number_of_processors)

  setup do
    reset_opensearch!
    reset_redis!
    reset_rack_attack!

    # We do it like this (rather than stub/unstub) so that we
    # can have this method globally without disabling mocha's
    # protections against unstubbing unecessary methods.
    return if @__skip_stubbing_rest_client__

    RestClient.define_method(:post) {}
    Bullet.start_request
  end

  teardown do
    Bullet.perform_out_of_channel_notifications if Bullet.notification?
    Bullet.end_request
  end

  # Create a few models and return a random one.
  # Use this method to guarantee that a method isn't
  # working because it's accessing the first or last
  # object created or stored in the db
  def random_of_many(model, params = {}, num: 3)
    Array(num).map { create(model, params) }.sample
  end

  def assert_equal_structs(expected, actual)
    assert_equal(JSON.parse(expected.to_json, object_class: OpenStruct), actual)
  end

  def assert_equal_arrays(expected, actual)
    assert_equal(expected.to_ary.sort, actual.to_ary.sort)
  end

  def assert_idempotent_command(&cmd)
    obj_1 = cmd.yield
    obj_2 = cmd.yield
    if obj_1.nil?
      assert_nil obj_2
    else
      assert_equal obj_1, obj_2
    end
  end

  def assert_html_equal(expected, actual)
    expected.gsub!(/^\s+/, '')
    expected.gsub!(/\s+$/, '')
    expected.delete!("\n")
    assert_equal(expected, actual)
  end

  def reset_redis!
    redis = Exercism.redis_tooling_client
    keys = redis.keys("#{Exercism.env}:*")
    redis.del(*keys) if keys.present?
  end

  def reset_rack_attack!
    Rack::Attack.reset!
  end

  ###################
  # Tooling Helpers #
  ###################
  def create_test_runner_job!(submission, execution_status: nil, results: nil, git_sha: nil)
    results ? execution_output = { "results.json" => results.to_json } : execution_output = nil
    create_tooling_job!(
      submission,
      :test_runner,
      execution_status:,
      execution_output:,
      source: {
        'exercise_git_sha' => git_sha || submission.git_sha
      }
    )
  end

  def create_representer_job!(submission, execution_status: nil, ast: nil, mapping: nil, metadata: nil, reason: nil, git_sha: nil)
    execution_output = {
      "representation.txt" => ast,
      "representation.json" => metadata&.to_json,
      "mapping.json" => mapping&.to_json
    }
    create_tooling_job!(
      submission,
      :representer,
      execution_status:,
      execution_output:,
      context: { reason: },
      source: {
        'exercise_git_sha' => git_sha || submission.git_sha
      }
    )
  end

  def create_analyzer_job!(submission, execution_status: nil, data: nil, tags_data: nil)
    execution_output = {
      "analysis.json" => data&.to_json,
      "tags.json" => tags_data&.to_json
    }
    create_tooling_job!(
      submission,
      :analyzer,
      execution_status:,
      execution_output:
    )
  end

  def create_tooling_job!(submission, type, params = {})
    Exercism::ToolingJob.create!(
      type,
      submission.uuid,
      submission.track.slug,
      submission.exercise.slug,
      **params
    )
  end

  def upload_to_s3(bucket, key, body) # rubocop:disable Naming/VariableNumber
    Exercism.s3_client.put_object(
      bucket:,
      key:,
      body:,
      acl: 'private'
    )
  end

  def download_s3_file(bucket, key)
    Exercism.s3_client.get_object(
      bucket:,
      key:
    ).body.read
  end

  ######################
  # OpenSearch Helpers #
  ######################
  def reset_opensearch!
    opensearch = Exercism.opensearch_client
    OPENSEARCH_INDEXES.each do |index|
      opensearch.indices.delete(index:) if opensearch.indices.exists(index:)
      opensearch.indices.create(index:)
    end
  end

  def get_opensearch_doc(index, id)
    Exercism.opensearch_client.get(index:, id:)
  rescue OpenSearch::Transport::Transport::Errors::NotFound
    nil
  end

  def wait_for_opensearch_to_be_synced
    # Wait for enqueued jobs to finish as opensearch is always updated from within jobs
    perform_enqueued_jobs

    # Force an index refresh to ensure there are no concurrent actions in the background
    OPENSEARCH_INDEXES.each do |index|
      Exercism.opensearch_client.indices.refresh(index:)
    end
  end

  def perform_enqueued_jobs_until_empty
    loop do
      perform_enqueued_jobs
      break if queue_adapter.enqueued_jobs.size.zero?
    end

    assert_no_enqueued_jobs
  end

  def stub_latest_track_forum_threads(track)
    stub_request(:get, "https://forum.exercism.org/c/programming/#{track.slug}/l/latest.json")
  end

  def generate_reputation_periods!
    # We use reputation periods for the calculation
    # This command should generate them all.
    User::ReputationToken.all.each { |t| User::ReputationPeriod::MarkForToken.(t) }
    User::ReputationPeriod::Sweep.()
  end

  ###############
  # N+1 Helpers #
  ###############
  def create_np1_data(mentor: nil)
    mentor ||= create :user

    2.times do
      user = create :user
      create(:user_profile, user:)

      # Reputation things
      create(:user_reputation_token, user:)

      # Relationships
      create :mentor_student_relationship, mentor:, student: user

      3.times do
        track = create :track, :random_slug
        exercise = create(:practice_exercise, track:)
        create(:user_track, track:, user:)

        # Submission things
        solution = create(:practice_solution, exercise:, user:)

        3.times do
          ast_digest = SecureRandom.uuid
          submission = create(:submission, solution:)
          create(:submission_representation, submission:, ast_digest:)
          create(:exercise_representation, exercise:, ast_digest:)
          create(:iteration, solution:)
          create :solution_comment, solution:
        end

        # Mentor things
        create(:user_track_mentorship, user: mentor, track:)
        create(:mentor_request, solution:)
        create :mentor_discussion, solution:
      end
    end
  end

  def assert_user_data_cache_reset(user, key, expected, &block)
    assert_nil user.data.reload.cache[key.to_s]

    perform_enqueued_jobs(&block)

    assert_equal expected, user.data.reload.cache[key.to_s]
  end

  def reset_user_cache(user)
    user.data.reload.update!(cache: nil)
    user.reload
  end

  OPENSEARCH_INDEXES = [
    Document::OPENSEARCH_INDEX,
    Solution::OPENSEARCH_INDEX,
    Exercise::Representation::OPENSEARCH_INDEX
  ].freeze
  private_constant :OPENSEARCH_INDEXES
end

class ActionView::TestCase
  include Devise::Test::ControllerHelpers

  def sign_in!(user = nil)
    @current_user = user || create(:user)
    @current_user.auth_tokens.create! unless @current_user.auth_tokens.exists?

    @current_user.confirm
    sign_in @current_user
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include TurboAssertionsHelper

  setup do
    host! URI(Rails.application.routes.default_url_options[:host]).host
  end

  def sign_in!(user = nil)
    @current_user = user || create(:user)
    @current_user.auth_tokens.create! unless @current_user.auth_tokens.exists?

    @current_user.confirm
    sign_in @current_user
  end

  # As we only use #page- prefix on ids for pages
  # this is a safe way of checking we've been positioned
  # on the right page during tests
  def assert_page(page)
    assert_includes @response.body, "<div id='page-#{page}'>"
  end

  def assert_rendered_404
    # TODO: (optional) Why doesn't this work?
    # assert_template file: "#{Rails.root}/public/404.html"
    assert_includes response.body, "Page not found"
  end
end

ActionDispatch::IntegrationTest.register_encoder :js,
  param_encoder: ->(params) { params },
  response_parser: ->(body) { body }
