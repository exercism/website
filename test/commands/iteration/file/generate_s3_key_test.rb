require 'test_helper'

class Iteration::File::GenerateS3KeyTest < ActiveSupport::TestCase
  test "generates correctly" do
    iteration_uuid = SecureRandom.uuid
    filename = "two_fer.rb"
    filename_hash = Digest::SHA1.hexdigest(filename)

    expected = "test/storage/#{iteration_uuid}/#{filename_hash}"
    assert_equal expected, Iteration::File::GenerateS3Key.(iteration_uuid, filename)
  end
end
