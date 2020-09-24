ENV['RAILS_ENV'] ||= 'test'

# This must happen above the env require below
if ENV["CAPTURE_CODE_COVERAGE"]
  require 'simplecov'
  SimpleCov.start 'rails'
end

require_relative '../config/environment'
require 'rails/test_help'
require 'mocha/minitest'
require 'minitest/pride'

# Configure mocach to be safe
Mocha.configure do |c|
  # c.stubbing_method_unnecessarily = :prevent
  c.stubbing_non_existent_method = :prevent
  c.stubbing_non_public_method = :warn
  c.stubbing_method_on_nil = :prevent
end

# Require the support helper files
Dir.foreach(Rails.root / "test" / "support") do |path|
  next if path.starts_with?('.')

  require Rails.root / "test" / "support" / path
end

module TestHelpers
  def self.git_repo_url(slug)
    "file://#{(Rails.root / 'test' / 'repos' / slug.to_s)}"
  end
end

class ActiveSupport::TimeWithZone
  def ==(other)
    to_i == other.to_i
  end
end

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
  include ActiveJob::TestHelper

  # Run tests in parallel with specified workers
  # parallelize(workers: :number_of_processors)

  def setup
    RestClient.stubs(:post)
  end

  # Create a few models and return a random one.
  # Use this method to guarantee that a method isn't
  # working because it's accessing the first or last
  # object created or stored in the db
  def random_of_many(model, params = {}, num: 3)
    Array(num).map { create(model, params) }.sample
  end

  def assert_idempotent_command(&cmd)
    obj_1 = cmd.yield
    obj_2 = cmd.yield
    assert_equal obj_1, obj_2
  end

  def write_to_dynamodb(table_name, item)
    client = ExercismConfig::SetupDynamoDBClient.()
    client.put_item(
      table_name: table_name,
      item: item
    )
  end

  def upload_to_s3(bucket, key, body)
    client = ExercismConfig::SetupS3Client.()
    client.put_object(
      bucket: bucket,
      key: key,
      body: body,
      acl: 'private'
    )
  end

  def download_s3_file(bucket, key)
    client = ExercismConfig::SetupS3Client.()
    client.get_object(
      bucket: bucket,
      key: key
    ).body.read
  end
end

class ActionDispatch::IntegrationTest
  # TODO: Add this when adding devise
  # include Devise::Test::IntegrationHelpers

  # TODO: Add this implmentation back when devise
  # is added.
  def sign_in!(user = nil)
    #  @current_user = user || create(:user, :onboarded)
    #  @current_user.confirm
    #  sign_in @current_user
  end

  def assert_correct_page(page)
    assert_includes @response.body, "<div id='#{page}'>"
  end
end

ActionDispatch::IntegrationTest.register_encoder :js,
                                                 param_encoder: ->(params) { params },
                                                 response_parser: ->(body) { body }
