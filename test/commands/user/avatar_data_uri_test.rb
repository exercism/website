require 'test_helper'

class User::AvatarDataUriTest < ActiveSupport::TestCase
  PNG_MAGIC_BYTES = "\x89PNG".b.freeze

  # A real PNG, so the thumbnailing pipeline has something it can actually decode.
  def png_bytes = File.binread(Rails.root.join("app", "images", "favicon.png"))

  test "inlines an attached avatar as a png data uri" do
    data_uri = User::AvatarDataUri.(create(:user))

    assert data_uri.start_with?("data:image/png;base64,")
    refute_empty Base64.strict_decode64(data_uri.split(',').last)
  end

  test "inlines an external avatar url as a png data uri" do
    # These users have no attachment - the bytes live on a third party, and we
    # fetch them here so that the generator's Lambda never has to.
    user = create :user, :external_avatar_url
    stub_request(:get, user.attributes['avatar_url']).to_return(
      body: png_bytes, headers: { 'Content-Type' => 'image/png' }
    )

    data_uri = User::AvatarDataUri.(user)

    assert data_uri.start_with?("data:image/png;base64,")
    assert Base64.strict_decode64(data_uri.split(',').last).start_with?(PNG_MAGIC_BYTES)
  end

  test "converts a non-png external avatar to png" do
    # satori sniffs magic bytes and ignores the data uri's mime label, so the
    # bytes themselves have to be a png regardless of what was uploaded.
    user = create :user, :external_avatar_url
    jpeg = ImageProcessing::Vips.source(Rails.root.join("app", "images", "favicon.png")).convert("jpg").()
    stub_request(:get, user.attributes['avatar_url']).to_return(
      body: File.binread(jpeg.path), headers: { 'Content-Type' => 'image/jpeg' }
    )

    data_uri = User::AvatarDataUri.(user)

    assert Base64.strict_decode64(data_uri.split(',').last).start_with?(PNG_MAGIC_BYTES)
  end

  test "fetches the external avatar every time, so avatar changes propagate immediately" do
    user = create :user, :external_avatar_url
    stub = stub_request(:get, user.attributes['avatar_url']).to_return(
      body: png_bytes, headers: { 'Content-Type' => 'image/png' }
    )

    3.times { User::AvatarDataUri.(user) }

    assert_requested stub, times: 3
  end

  test "returns nil rather than raising when the external avatar cannot be fetched" do
    user = create :user, :external_avatar_url
    stub_request(:get, user.attributes['avatar_url']).to_timeout

    Sentry.expects(:capture_exception).at_least_once

    assert_nil User::AvatarDataUri.(user)
  end

  test "returns nil rather than raising when the external avatar host errors" do
    user = create :user, :external_avatar_url
    stub_request(:get, user.attributes['avatar_url']).to_return(status: 500)

    Sentry.expects(:capture_exception).at_least_once

    assert_nil User::AvatarDataUri.(user)
  end

  test "returns nil rather than raising when the external avatar is not an image" do
    user = create :user, :external_avatar_url
    stub_request(:get, user.attributes['avatar_url']).to_return(
      body: "<html>Not found</html>", headers: { 'Content-Type' => 'text/html' }
    )

    Sentry.expects(:capture_exception).at_least_once

    assert_nil User::AvatarDataUri.(user)
  end

  test "returns nil when there is no avatar at all" do
    # The generator draws its own placeholder circle when it has no avatar, so
    # there is nothing to gain from inlining a placeholder here.
    user = create :user, :external_avatar_url
    user.update_column(:avatar_url, nil)

    assert_nil User::AvatarDataUri.(user.reload)
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
