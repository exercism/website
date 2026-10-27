require "test_helper"

class User::UpdateAvatarTest < ActiveSupport::TestCase
  setup do
    @avatar = upload_file("image.png", File.read(Rails.root.join("app", "images", "world-map.png")), 'image/png')
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

  test "accepts jpeg, gif and webp images" do
    user = create :user
    source = Rails.root.join("app", "images", "favicon.png")

    %w[jpg gif webp].each do |format|
      converted = ImageProcessing::Vips.source(source).convert(format).()
      User::UpdateAvatar.(user, upload_file("image.#{format}", File.binread(converted.path), "image/#{format}"))

      assert user.reload.avatar.attached?
    end
  end

  test "rejects svg images" do
    user = create :user, version: 15
    svg = upload_file("image.svg", '<svg xmlns="http://www.w3.org/2000/svg" width="10" height="10"></svg>', 'image/svg+xml')

    error = assert_raises ActiveRecord::RecordInvalid do
      User::UpdateAvatar.(user, svg)
    end

    assert_includes error.record.errors[:avatar], "must be a PNG, JPEG, GIF or WebP image"
    assert_equal "image/png", user.reload.avatar.content_type
    assert_equal 15, user.version
  end

  test "rejects files that are not images" do
    user = create :user
    html = upload_file("image.html", "<html><body>Hello</body></html>", 'text/html')

    assert_raises ActiveRecord::RecordInvalid do
      User::UpdateAvatar.(user, html)
    end
  end

  private
  def upload_file(filename, content, content_type)
    tempfile = Tempfile.new([SecureRandom.uuid, File.extname(filename)])
    tempfile.binmode
    tempfile.write(content)
    tempfile.rewind
    Rack::Test::UploadedFile.new(tempfile.path, content_type)
  end
end
