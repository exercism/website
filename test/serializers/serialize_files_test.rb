require 'test_helper'

class SerializeFilesTest < ActiveSupport::TestCase
  test "serializes files" do
    files = { "bob.rb" => "content" }

    assert_equal [{ filename: "bob.rb", content: "content" }], SerializeFiles.(files)
  end
end
