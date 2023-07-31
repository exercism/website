require 'test_helper'

class SerializeFilesWithMetadataTest < ActiveSupport::TestCase
  test "serializes files" do
    files = {
      "bob.rb" => {
        type: :exercise,
        content: "content",
        digest: "123"
      }
    }

    expected = [{ filename: "bob.rb", digest: "123", type: :exercise, content: "content" }]
    assert_equal expected, SerializeFilesWithMetadata.(files)
  end
end
