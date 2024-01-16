require "test_helper"

class User::UpdateAvatarTest < ActiveSupport::TestCase
  setup do
    filename = "world-map.png"
    tempfile = Tempfile.new([SecureRandom.uuid, '.png'])
    tempfile.write(File.read(Rails.root.join("app", "images", filename)))
    tempfile.rewind
    @avatar = Rack::Test::UploadedFile.new(tempfile.path, 'image/png')
  end

  test "updates avatar" do
    user = create :user
    user.avatar.purge
    refute user.avatar.attached?

    User::UpdateAvatar.(user, @avatar)
    assert user.avatar.attached?
  end

  test "bumps version" do
    user = create :user, version: 15

    User::UpdateAvatar.(user, @avatar)

    assert_equal 16, user.version
  end
end
