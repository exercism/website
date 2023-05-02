class ApplicationJob < ActiveJob::Base
  # For some errors we want to put the job back on the queue by raising and
  # letting Sidekiq handle things, but don't want to raise the exceptions
  # to bugsnag. This block handles that.
  skip_bugnag_and_raise = lambda do |exception|
    exception.define_singleton_method(:skip_bugsnag) { true }
    raise exception
  end
  rescue_from ActiveRecord::Deadlocked, &skip_bugnag_and_raise
  rescue_from ActiveJob::DeserializationError, &skip_bugnag_and_raise

  include Bullet::ActiveJob if Rails.env.development?
end
