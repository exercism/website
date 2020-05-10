require 'test_helper'

class IterationFileTest < ActiveSupport::TestCase
  test "digest is generated correctly" do
    content = "The cat\nsat on the\mnproverbial mat"
    md5 = Digest::MD5.new
    md5.update(content)
    digest = md5.hexdigest 
    
    iteration = create :iteration

    file = IterationFile.create!(
      iteration: iteration, 
      filename: "something.rb",
      content: content
    )
    assert_equal digest, file.digest
  end
end
