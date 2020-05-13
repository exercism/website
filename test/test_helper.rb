ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'mocha/minitest'
require 'timecop'

module TestHelpers
  def self.git_repo_url(slug)
    "file://#{(Rails.root / "test" / "repos" / slug.to_s)}"
  end
end

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  # Run tests in parallel with specified workers
  #parallelize(workers: :number_of_processors)
  parallelize(workers: 1)

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
end

