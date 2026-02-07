require "test_helper"

class BugsnagActiveStorageFilterTest < ActiveSupport::TestCase
  test "discards RecordNotFound from ActiveStorage paths" do
    event = mock_bugsnag_event(
      error_class: "ActiveRecord::RecordNotFound",
      url: "https://exercism.org/rails/active_storage/representations/redirect/abc123/variant/avatar.jpg"
    )

    result = BUGSNAG_ACTIVE_STORAGE_FILTER.(event)
    refute result
  end

  test "allows RecordNotFound from non-ActiveStorage paths" do
    event = mock_bugsnag_event(
      error_class: "ActiveRecord::RecordNotFound",
      url: "https://exercism.org/tracks/ruby"
    )

    result = BUGSNAG_ACTIVE_STORAGE_FILTER.(event)
    refute_equal false, result
  end

  test "allows other errors from ActiveStorage paths" do
    event = mock_bugsnag_event(
      error_class: "StandardError",
      url: "https://exercism.org/rails/active_storage/representations/redirect/abc123/variant/avatar.jpg"
    )

    result = BUGSNAG_ACTIVE_STORAGE_FILTER.(event)
    refute_equal false, result
  end

  test "handles events with no errors" do
    event = stub(errors: [])

    result = BUGSNAG_ACTIVE_STORAGE_FILTER.(event)
    refute_equal false, result
  end

  private
  def mock_bugsnag_event(error_class:, url:)
    error = stub(error_class: error_class)
    stub(errors: [error], request: { url: url })
  end
end
