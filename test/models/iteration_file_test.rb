require 'test_helper'

class IterationFileTest < ActiveSupport::TestCase
  test "digest is generated correctly" do
    contents = "The cat\nsat on the\mnproverbial mat"
    md5 = Digest::MD5.new
    md5.update(contents)
    digest = md5.hexdigest 
    
    iteration = create :iteration

    file = IterationFile.create!(
      iteration: iteration, 
      filename: "something.rb",
      contents: contents
    )
    assert_equal digest, file.digest
  end
end
