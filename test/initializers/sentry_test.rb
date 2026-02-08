require "test_helper"

class SentryActiveStorageFilterTest < ActiveSupport::TestCase
  test "discards RecordNotFound from ActiveStorage paths" do
    event = mock_sentry_event(url: "https://exercism.org/rails/active_storage/representations/redirect/abc123/variant/avatar.jpg")
    hint = { exception: ActiveRecord::RecordNotFound.new }

    result = SENTRY_ACTIVE_STORAGE_FILTER.(event, hint)
    assert_nil result
  end

  test "allows RecordNotFound from non-ActiveStorage paths" do
    event = mock_sentry_event(url: "https://exercism.org/tracks/ruby")
    hint = { exception: ActiveRecord::RecordNotFound.new }

    result = SENTRY_ACTIVE_STORAGE_FILTER.(event, hint)
    assert_equal event, result
  end

  test "allows other errors from ActiveStorage paths" do
    event = mock_sentry_event(url: "https://exercism.org/rails/active_storage/representations/redirect/abc123/variant/avatar.jpg")
    hint = { exception: StandardError.new }

    result = SENTRY_ACTIVE_STORAGE_FILTER.(event, hint)
    assert_equal event, result
  end

  test "handles events with no exception in hint" do
    event = mock_sentry_event(url: "https://exercism.org/tracks/ruby")
    hint = {}

    result = SENTRY_ACTIVE_STORAGE_FILTER.(event, hint)
    assert_equal event, result
  end

  private
  def mock_sentry_event(url:)
    request = stub(url: url)
    stub(request: request)
  end
end
