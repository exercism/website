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

  class TestDeserializationWithUserJob < ApplicationJob
    def perform(user)
      user.update(name: "new")
    end
  end

  test "deadlock raises but skips bugsnag" do
    exception = assert_raises ActiveRecord::Deadlocked do
      TestDeadlockedJob.perform_now
    end

    assert exception.skip_bugsnag
  end

  test "Deserialization raises for non-active-record exception" do
    exception = assert_raises ActiveJob::DeserializationError do
      TestDeserializationJob.perform_now
    end

    # Check we don't skip bugsnag (this is the weird way to do it)
    assert_raises(NoMethodError) do
      exception.skip_bugsnag
    end
  end

  test "Deserialization drops the job with a missing model" do
    # Don't sleep when testing things else we'll be here all day!
    Mocha::Configuration.override(stubbing_non_public_method: :allow) do
      ApplicationJob.any_instance.stubs(:sleep)
    end

    user = create :user
    user.destroy

    User.expects(:find).with(user.id.to_s).raises(ActiveRecord::RecordNotFound)
    perform_enqueued_jobs do
      TestDeserializationWithUserJob.perform_later(user)
    end
  end

  test "Deserialization drops silently if record is gone" do
    # Don't sleep when testing things else we'll be here all day!
    Mocha::Configuration.override(stubbing_non_public_method: :allow) do
      ApplicationJob.any_instance.stubs(:sleep)
    end

    user = create :user
    user.destroy

    exception = ActiveRecord::RecordNotFound.new('', 'User', :id, user.id.to_s)
    User.expects(:find).with(user.id.to_s).raises(exception).times(21)

    perform_enqueued_jobs do
      TestDeserializationWithUserJob.perform_later(user)
    end
  end

  test "Deserialization retries then runs if model appears successfully" do
    user = create :user
    user.destroy

    # In a seperate thread, recreate the user. This will happen in between the
    # first deserialiation error and the second lookup check.
    Thread.new do
      sleep(0.2)
      create :user, id: user.id, name: 'old'
    end

    perform_enqueued_jobs do
      TestDeserializationWithUserJob.perform_later(user)
    end

    # The job should change this.
    assert_equal 'new', user.reload.name
  end
end
