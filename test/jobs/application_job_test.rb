require "test_helper"

class ApplicationJobTest < ActiveJob::TestCase
  class TestDeadlockedJob < ApplicationJob
    def perform
      raise ActiveRecord::Deadlocked
    end
  end

  class TestDeserializationJob < ApplicationJob
    def perform
      # ActiveJob::DeserializationError uses $! so this needs
      # wrapping like this.

      raise
    rescue StandardError
      raise ActiveJob::DeserializationError
    end
  end

  test "deadlock raises but skips bugsnag" do
    exception = assert_raises ActiveRecord::Deadlocked do
      TestDeadlockedJob.perform_now
    end

    assert exception.skip_bugsnag
  end

  test "Deserialization raises but skips bugsnag" do
    exception = assert_raises ActiveJob::DeserializationError do
      TestDeserializationJob.perform_now
    end

    assert exception.skip_bugsnag
  end
end
