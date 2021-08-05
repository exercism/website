require 'test_helper'

class SerializeFilesTest < ActiveSupport::TestCase
  test "serializes files" do
    files = {
      "bob.rb" => {
        type: :exercise,
        content: "content"
      }
    }

    assert_equal [{ filename: "bob.rb", type: :exercise, content: "content" }], SerializeFiles.(files)
  end
end
