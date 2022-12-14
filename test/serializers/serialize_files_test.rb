require 'test_helper'

class SerializeFilesTest < ActiveSupport::TestCase
  test "serializes files" do
    files = {
      "bob.rb" => "hey bob",
      "test.rb" => "test 123"
    }

    expected = [
      { filename: "bob.rb", content: "hey bob" },
      { filename: "test.rb", content: "test 123" }
    ]
    assert_equal expected, SerializeFiles.(files)
  end
end
