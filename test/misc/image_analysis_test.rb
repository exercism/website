require "test_helper"

class ImageAnalysisTest < ActiveSupport::TestCase
  test "image analysis works" do
    user = create :user
    user.avatar.attach(io: File.open(Rails.root.join("test", "fixtures", "test.jpg")),
      filename: "test.jpg",
      content_type: "image/jpeg")

    user.avatar.analyze

    blob = ActiveStorage::Blob.last
    refute_nil blob.metadata["width"]
    refute_nil blob.metadata["height"]
  end
end
