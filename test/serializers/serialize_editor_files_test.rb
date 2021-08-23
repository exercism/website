require 'test_helper'

class SerializeEditorFilesTest < ActiveSupport::TestCase
  test "serializes files" do
    files = {
      "bob.rb" => {
        type: :exercise,
        content: "content",
        digest: "123"
      }
    }

    assert_equal [{ filename: "bob.rb", type: :exercise, content: "content" }], SerializeEditorFiles.(files)
  end
end
