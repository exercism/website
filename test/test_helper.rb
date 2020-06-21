ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'mocha/minitest'
require 'minitest/pride'
require 'timecop'

# Configure mocach to be safe
Mocha.configure do |c|
  #c.stubbing_method_unnecessarily = :prevent
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
    "file://#{(Rails.root / "test" / "repos" / slug.to_s)}"
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
  parallelize(workers: :number_of_processors)

  def setup
    RestClient.stubs(:post)
  end

  # Create a few models and return a random one.
  # Use this method to guarantee that a method isn't
  # working because it's accessing the first or last 
  # object created or stored in the db
  def random_of_many(model, params = {}, num: 3)
    num.times.map { create(model, params) }.sample
  end

  def assert_idempotent_command(&cmd)
    obj1 = cmd.call
    obj2 = cmd.call
    assert_equal obj1, obj2
  end
end

