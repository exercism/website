require 'test_helper'

class Iteration::PrepareMappedFilesTest < ActiveSupport::TestCase
  test "remaps correctly" do
    filename_1 = "subdir/foobar.rb"
    content_1 = "'I think' = 'I am'"

    filename_2 = "barfood.rb"
    content_2 = "something = :else"

    files = Iteration::PrepareMappedFiles.({
                                             filename_1 => content_1,
                                             filename_2 => content_2
                                           })

    assert_equal 2, files.count

    first_file = files.first
    assert_equal filename_1, first_file[:filename]
    assert_equal content_1, first_file[:content]

    second_file = files.last
    assert_equal filename_2, second_file[:filename]
    assert_equal content_2, second_file[:content]
  end

  test "raises if file is too large" do
    filename = "subdir/foobar.rb"
    content = Array.new(1.megabyte + 1, 'x')

    assert_raises IterationFileTooLargeError do
      Iteration::PrepareMappedFiles.({ filename => content })
    end
  end
end
