require 'test_helper'

class Submission::PrepareHttpFilesTest < ActiveSupport::TestCase
  test "extracts contents correctly" do
    filename_1 = "subdir/foobar.rb"
    content_1 = "'I think' = 'I am'"
    headers_1 = "Content-Disposition: form-data; name=\"files[]\"; filename=\"#{filename_1}\"\r\nContent-Type: application/octet-stream\r\n" # rubocop:disable Layout/LineLength
    file_1 = mock(read: content_1, headers: headers_1)

    filename_2 = "barfood.rb"
    content_2 = "something = :else"
    headers_2 = "Content-Disposition: form-data; name=\"files[]\"; filename=\"#{filename_2}\"\r\nContent-Type: application/octet-stream\r\n" # rubocop:disable Layout/LineLength
    file_2 = mock(read: content_2, headers: headers_2)

    files = Submission::PrepareHttpFiles.([file_1, file_2])

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
    headers = "Content-Disposition: form-data; name=\"files[]\"; filename=\"#{filename}\"\r\nContent-Type: application/octet-stream\r\n" # rubocop:disable Layout/LineLength
    file = mock(read: content, headers:)

    assert_raises SubmissionFileTooLargeError do
      Submission::PrepareHttpFiles.([file])
    end
  end
end
