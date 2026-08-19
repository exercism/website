require 'test_helper'

class User::AvatarDataUriTest < ActiveSupport::TestCase
  test "inlines an attached avatar as a png data uri" do
    data_uri = User::AvatarDataUri.(create(:user))

    assert data_uri.start_with?("data:image/png;base64,")
    refute_empty Base64.strict_decode64(data_uri.split(',').last)
  end

  test "returns nil when there is no attached avatar" do
    # These users have an external avatar_url instead, which the generator
    # fetches itself - there is nothing in S3 for us to inline.
    assert_nil User::AvatarDataUri.(create(:user, :external_avatar_url))
  end

  test "returns nil rather than raising when the variant cannot be produced" do
    # A broken avatar must degrade to the avatar_url fallback, never fail the
    # render it is part of.
    user = create :user
    user.avatar.stubs(:variant).raises(StandardError.new("could not process"))

    Sentry.expects(:capture_exception).once

    assert_nil User::AvatarDataUri.(user)
  end
end
