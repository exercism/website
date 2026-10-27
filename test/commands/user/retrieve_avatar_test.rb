require "test_helper"

class User::RetrieveAvatarTest < ActiveSupport::TestCase
  SVG = '<svg xmlns="http://www.w3.org/2000/svg"></svg>'.freeze

  def png_bytes = File.binread(Rails.root.join("app", "images", "favicon.png"))

  test "returns an attached avatar" do
    user = create :user

    data, content_type = User::RetrieveAvatar.(user)

    assert_equal "image/png", content_type
    assert_equal png_bytes, data
  end

  test "returns the placeholder for an attached avatar in another format" do
    user = create :user
    attach_svg_avatar!(user)
    stub_placeholder

    data, content_type = User::RetrieveAvatar.(User.find(user.id))

    assert_equal "image/svg+xml", content_type
    assert_equal "placeholder", data
  end

  test "returns an external avatar" do
    user = create :user, :external_avatar_url
    stub_request(:get, user.attributes['avatar_url']).to_return(
      body: png_bytes, headers: { 'Content-Type' => 'image/png' }
    )

    data, content_type = User::RetrieveAvatar.(user)

    assert_equal "image/png", content_type
    assert_equal png_bytes, data
  end

  test "returns the placeholder for an external avatar in another format" do
    user = create :user, :external_avatar_url
    stub_placeholder

    %w[image/svg+xml text/html].each do |external_content_type|
      stub_request(:get, user.attributes['avatar_url']).to_return(
        body: SVG, headers: { 'Content-Type' => external_content_type }
      )

      data, content_type = User::RetrieveAvatar.(user)

      assert_equal "image/svg+xml", content_type
      assert_equal "placeholder", data
    end
  end

  test "returns the placeholder when there is no avatar" do
    user = create :user, :external_avatar_url
    user.update_column(:avatar_url, nil)
    stub_placeholder

    data, content_type = User::RetrieveAvatar.(user.reload)

    assert_equal "image/svg+xml", content_type
    assert_equal "placeholder", data
  end

  private
  def stub_placeholder
    stub_request(:get, User::RetrieveAvatar.placeholder_url).to_return(
      body: "placeholder", headers: { 'Content-Type' => 'image/svg+xml' }
    )
  end

  # Older avatars may predate the format check, so attach one directly.
  def attach_svg_avatar!(user)
    user.avatar.purge
    blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new(SVG), filename: "avatar.svg", content_type: "image/svg+xml"
    )
    ActiveStorage::Attachment.create!(record: user, name: "avatar", blob:)
  end
end
