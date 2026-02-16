class ApplicationJob < ActiveJob::Base
  # Retry deadlocked jobs without reporting to Sentry
  # (excluded via Sentry config's excluded_exceptions)
  retry_on ActiveRecord::Deadlocked

  # Retry jobs that fail due to transient AWS credential errors
  # (e.g. during credential rotation or ECS task role refresh)
  retry_on Aws::Sigv4::Errors::MissingCredentialsError,
    Aws::Errors::MissingCredentialsError,
    wait: 10.seconds, attempts: 3

  # Retry jobs that fail due to transient network connection errors
  # (e.g. remote server closing connection, brief network interruptions)
  retry_on Faraday::ConnectionFailed,
    wait: 5.seconds, attempts: 5

  # Can be overriden to disable this
  def guard_against_deserialization_errors? = true
  rescue_from ActiveJob::DeserializationError do |exception|
    raise exception unless guard_against_deserialization_errors?

    # We expect this to be a record not found. If it's not
    # then get out of here and go via Sentry!
    raise exception unless exception.cause.is_a?(ActiveRecord::RecordNotFound)

    # Let any transactions finish then look up again
    # If the thing is now found, requeue the job.
    # Or if it's still missing, just kill the job. This happens if
    # the record is deleted in the time it takes to execute the job
    # (e.g. a User's records being deleted)

    # Sleep for a total of 5 seconds (20*0.25). This is rare enough
    # that we don't mind locking the jobs for this duration.
    # It's worse to drop jobs by accident.
    20.times do
      sleep(0.25)

      begin
        exception.cause.model.constantize.find(exception.cause.id)
        retry_job
        break
      rescue NoMethodError, ActiveRecord::RecordNotFound
        # Continue to loop
      end
    end

    # If we get to this point, the model has gone
    # so just exit the job which removes it from sidekiq
  end

  include Bullet::ActiveJob if Rails.env.development?
end
