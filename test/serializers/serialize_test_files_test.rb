require 'test_helper'

class SerializeTestFilesTest < ActiveSupport::TestCase
  test "serializes test files" do
    files = { "bob_test.rb" => "test" }

    assert_equal [{ filename: "bob_test.rb", content: "test" }], SerializeTestFiles.(files)
  end
end
