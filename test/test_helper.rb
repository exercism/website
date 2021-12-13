ENV['RAILS_ENV'] ||= 'test'

require_relative '../config/environment'
require 'rails/test_help'
require 'mocha/minitest'
require 'minitest/pride'
require 'webmock/minitest'
require 'minitest/retry'
require_relative './helpers/turbo_assertions_helper'

# Handle flakey tests in CI
Minitest::Retry.use!(retry_count: 3) if ENV["EXERCISM_CI"]

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

module TestHelpers
  extend Webpacker::Helper
  extend ActionView::Helpers::AssetUrlHelper

  def self.git_repo_url(slug)
    "file://#{Rails.root / 'test' / 'repos' / slug.to_s}"
  end

  def self.use_website_copy_test_repo!
    repo_url = TestHelpers.git_repo_url("website-copy")
    Git::WebsiteCopy.new(repo_url: repo_url).tap do |repo|
      Git::WebsiteCopy.expects(:new).at_least_once.returns(repo)
    end
  end

  def self.use_blog_test_repo!
    repo_url = TestHelpers.git_repo_url("blog")
    repo = Git::Blog.new(repo_url: repo_url)
    Git::Blog.expects(:new).at_least_once.returns(repo)
  end

  def self.use_docs_test_repo!
    repo_url = TestHelpers.git_repo_url("docs")
    repo = Git::Repository.new(repo_url: repo_url)
    Git::Repository.expects(:new).at_least_once.returns(repo)
  end

  def self.image_pack_url(icon_name, category: 'icons')
    asset_pack_url("media/images/#{category}/#{icon_name}.svg")
  end
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
  def assert_email(email, to, subject, fixture)
    # Test email can send ok
    assert_emails 1 do
      email.deliver_now
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal ["hello@mail.exercism.io"], email.from
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

  def setup
    # Clear out elasticsearch
    reset_opensearch!

    # Clear out redis
    redis = Exercism.redis_tooling_client
    keys = redis.keys("#{Exercism.env}:*")
    redis.del(*keys) if keys.present?

    # We do it like this (rather than stub/unstub) so that we
    # can have this method globally without disabling mocha's
    # protections against unstubbing unecessary methods.
    return if @__skip_stubbing_rest_client__

    RestClient.define_method(:post) {}
  end

  # Create a few models and return a random one.
  # Use this method to guarantee that a method isn't
  # working because it's accessing the first or last
  # object created or stored in the db
  def random_of_many(model, params = {}, num: 3)
    Array(num).map { create(model, params) }.sample
  end

  def assert_equal_arrays(expected, actual)
    assert_equal(expected.to_ary.sort, actual.to_ary.sort)
  end

  def assert_idempotent_command(&cmd)
    obj_1 = cmd.yield
    obj_2 = cmd.yield
    assert_equal obj_1, obj_2
  end

  def assert_html_equal(expected, actual)
    expected.gsub!(/^\s+/, '')
    expected.gsub!(/\s+$/, '')
    expected.delete!("\n")
    assert_equal(expected, actual)
  end

  ###################
  # Tooling Helpers #
  ###################
  def create_test_runner_job!(submission, execution_status: nil, results: nil, git_sha: nil)
    results ? execution_output = { "results.json" => results.to_json } : execution_output = nil
    create_tooling_job!(
      submission,
      :test_runner,
      execution_status: execution_status,
      execution_output: execution_output,
      source: {
        'exercise_git_sha' => git_sha || submission.git_sha
      }
    )
  end

  def create_representer_job!(submission, execution_status: nil, ast: nil, mapping: nil)
    execution_output = {
      "representation.txt" => ast,
      "mapping.json" => mapping&.to_json
    }
    create_tooling_job!(
      submission,
      :representer,
      execution_status: execution_status,
      execution_output: execution_output
    )
  end

  def create_analyzer_job!(submission, execution_status: nil, data: nil)
    execution_output = {
      "analysis.json" => data&.to_json
    }
    create_tooling_job!(
      submission,
      :analyzer,
      execution_status: execution_status,
      execution_output: execution_output
    )
  end

  def create_tooling_job!(submission, type, params = {})
    ToolingJob::Create.(
      type,
      submission.uuid,
      submission.track.slug,
      submission.exercise.slug,
      params
    )
  end

  def upload_to_s3(bucket, key, body) # rubocop:disable Naming/VariableNumber
    Exercism.s3_client.put_object(
      bucket: bucket,
      key: key,
      body: body,
      acl: 'private'
    )
  end

  def download_s3_file(bucket, key)
    Exercism.s3_client.get_object(
      bucket: bucket,
      key: key
    ).body.read
  end

  ######################
  # OpenSearch Helpers #
  ######################
  def reset_opensearch!
    opensearch = Exercism.opensearch_client
    [Document::OPENSEARCH_INDEX, Solution::OPENSEARCH_INDEX].each do |index|
      opensearch.indices.delete(index: index) if opensearch.indices.exists(index: index)
      opensearch.indices.create(index: index)
    end
  end

  def get_opensearch_doc(index, id)
    Exercism.opensearch_client.get(index: index, id: id)
  end

  def wait_for_opensearch_to_be_synced
    # Wait for enqueued jobs to finish as opensearch is always updated from within jobs
    perform_enqueued_jobs

    # Force an index refresh to ensure there are no concurrent actions in the background
    [Document::OPENSEARCH_INDEX, Solution::OPENSEARCH_INDEX].each do |index|
      Exercism.opensearch_client.indices.refresh(index: index)
    end
  end
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
