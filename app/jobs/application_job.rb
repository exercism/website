class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  rescue_from ActiveRecord::Deadlocked do |exception|
    exception.instance_eval do
      def skip_bugsnag
        true
      end
    end
    raise exception
  end

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError
end
