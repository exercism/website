require "test_helper"

class TranslationRepo::SyncOnBootTest < ActiveSupport::TestCase
  setup { TranslationRepo.expire! }
  teardown { TranslationRepo.expire! }

  test "syncs and succeeds" do
    TranslationRepo::Sync.expects(:call).once.returns(true)
    Sentry.expects(:capture_exception).never
    Sentry.expects(:capture_message).never

    assert TranslationRepo::SyncOnBoot.()
  end

  test "carries on when another process holds the lock and a checkout is present" do
    TranslationRepo::Sync.expects(:call).once.returns(false)
    TranslationRepo.stubs(version: SecureRandom.hex(20))
    Sentry.expects(:capture_exception).never
    Sentry.expects(:capture_message).never

    assert TranslationRepo::SyncOnBoot.()
  end

  test "waits for the process holding the lock while there is no checkout" do
    TranslationRepo.stubs(version: nil)
    TranslationRepo::Sync.expects(:call).twice.returns(false, true)

    assert TranslationRepo::SyncOnBoot.(retry_interval_seconds: 0.01)
  end

  test "gives up and reports once there is no checkout and the timeout passes" do
    TranslationRepo.stubs(version: nil)
    TranslationRepo::Sync.stubs(:call).returns(false)
    Sentry.expects(:capture_message).once.with do |message, **opts|
      message.include?("gave up") && opts[:level] == :error
    end

    refute TranslationRepo::SyncOnBoot.(timeout_seconds: 0.05, retry_interval_seconds: 0.01)
  end

  test "reports a failing sync but boots on the existing checkout" do
    TranslationRepo::Sync.expects(:call).once.raises("git pull failed: nope")
    TranslationRepo.stubs(version: SecureRandom.hex(20))
    Sentry.expects(:capture_exception).once.with do |error, **opts|
      error.message == "git pull failed: nope" && opts[:level] == :warning
    end

    assert TranslationRepo::SyncOnBoot.()
  end

  test "reports a failing sync as an error when there is no checkout" do
    TranslationRepo.stubs(version: nil)
    TranslationRepo::Sync.stubs(:call).raises("git clone failed: nope")
    Sentry.expects(:capture_exception).once.with do |error, **opts|
      error.message == "git clone failed: nope" && opts[:level] == :error
    end

    refute TranslationRepo::SyncOnBoot.(timeout_seconds: 0.05, retry_interval_seconds: 0.01)
  end
end
