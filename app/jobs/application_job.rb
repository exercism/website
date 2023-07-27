class ApplicationJob < ActiveJob::Base
  # For some errors we want to put the job back on the queue by raising and
  # letting Sidekiq handle things, but don't want to raise the exceptions
  # to bugsnag. This block handles that.
  skip_bugnag_and_raise = lambda do |exception|
    exception.define_singleton_method(:skip_bugsnag) { true }
    raise exception
  end

  rescue_from ActiveRecord::Deadlocked, &skip_bugnag_and_raise
  rescue_from ActiveJob::DeserializationError do |exception|
    # We except this to be a record not found. If it's not
    # then get out of here
    skip_bugnag_and_raise.() unless exception.cause.is_a?(ActiveRecord::RecordNotFound)

    # Let any transactions finish then look up again
    # If the thing is now found, requeue the job.
    # Or if it's still missing, just kill the job. This happens if
    # the record is deleted in the time it takes to execute the job
    # (e.g. a User's records being deleted)
    sleep(0.5)
    begin
      exception.cause.model.constantize.find(exception.cause.id)
      retry_job
    rescue ActiveRecord::RecordNotFound
      # The record is gone, kill the job
    end
  end

  include Bullet::ActiveJob if Rails.env.development?
end
