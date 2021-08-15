require 'test_helper'

class SerializeFilesTest < ActiveSupport::TestCase
  test "serializes files" do
    files = {
      "bob.rb" => {
        type: :exercise,
        content: "content",
        digest: "123"
      }
    }

    assert_equal [{ filename: "bob.rb", digest: "123", type: :exercise, content: "content" }], SerializeFiles.(files)
  end
end
