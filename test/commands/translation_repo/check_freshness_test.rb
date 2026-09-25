require "test_helper"

class TranslationRepo::CheckFreshnessTest < ActiveSupport::TestCase
  setup { Rails.cache.clear }

  test "stays quiet while the site serves main" do
    serve!("a" * 40, main: "a" * 40)
    Sentry.expects(:capture_message).never

    TranslationRepo::CheckFreshness.()
  end

  test "stays quiet while the site has been behind for less than the limit" do
    serve!("a" * 40, main: "b" * 40)
    Sentry.expects(:capture_message).never

    TranslationRepo::CheckFreshness.()
    travel(29.minutes) { TranslationRepo::CheckFreshness.() }
  end

  test "reports once the site has served the same commit behind main for longer than the limit" do
    serve!("a" * 40, main: "b" * 40)
    TranslationRepo::CheckFreshness.()

    serve!("a" * 40, main: "c" * 40)
    Sentry.expects(:capture_message).once.with do |message, **opts|
      message.include?("serving #{'a' * 40}, main is #{'c' * 40}") &&
        opts[:level] == :error && opts[:fingerprint] == ["translations-stale"]
    end

    travel(31.minutes) { TranslationRepo::CheckFreshness.() }
  end

  test "restarts the clock when the site moves to a new commit" do
    serve!("a" * 40, main: "c" * 40)
    TranslationRepo::CheckFreshness.()

    serve!("b" * 40, main: "c" * 40)
    Sentry.expects(:capture_message).never

    travel(31.minutes) { TranslationRepo::CheckFreshness.() }
  end

  test "reports when there is no checkout at all" do
    serve!(nil, main: "b" * 40)
    TranslationRepo::CheckFreshness.()

    Sentry.expects(:capture_message).once.with { |message, **| message.include?("serving nothing") }

    travel(31.minutes) { TranslationRepo::CheckFreshness.() }
  end

  test "raises when main cannot be read" do
    TranslationRepo.stubs(version: "a" * 40)
    Open3.stubs(:capture2e).returns(["fatal: unable to access", stub(success?: false)])

    assert_raises(RuntimeError) { TranslationRepo::CheckFreshness.() }
  end

  private
  def serve!(sha, main:)
    TranslationRepo.stubs(version: sha)
    Open3.stubs(:capture2e).with("git", "ls-remote", TranslationRepo::URL, "refs/heads/main").
      returns(["#{main}\trefs/heads/main\n", stub(success?: true)])
  end
end
