require 'test_helper'

class User::SubmitIterationTest < ActiveSupport::TestCase
  test "creates iteration" do
    solution = create :concept_solution
    filename_1 = "subdir/foobar.rb"
    content_1 = "'I think' = 'I am'"
    digest_1 = "digest #1"

    filename_2 = "barfood.rb"
    content_2 = "something = :else"
    digest_2 = "digest #2"
 
    files = [
      { filename: filename_1, content: content_1 },
      { filename: filename_2, content: content_2 }
    ]

    iteration = User::SubmitIteration.(solution, files)

    assert iteration.persisted?
    assert_equal iteration.solution, solution
    assert_equal 2, iteration.files.count

    first_file = iteration.files.first
    assert_equal filename_1, first_file.filename
    assert_equal content_1, first_file.content

    second_file = iteration.files.last
    assert_equal filename_2, second_file.filename
    assert_equal content_2, second_file.content
  end

  test "guards against duplicates" do
    solution = create :concept_solution
    filename_1 = "subdir/foobar.rb"
    content_1 = "'I think' = 'I am'"
    digest_1 = "digest #1"

    filename_2 = "barfood.rb"
    content_2 = "something = :else"
    digest_2 = "digest #2"
 
    files = [
      { filename: filename_1, content: content_1 },
      { filename: filename_2, content: content_2 }
    ]

    # Do it once successfully
    User::SubmitIteration.(solution, files)

    # The second time *in a row* it should fail
    assert_raises User::SubmitIteration::DuplicateIterationError do
      User::SubmitIteration.(solution, files)
    end

    # Submit something different
    User::SubmitIteration.(solution, [files.first])

    # The duplicate should now succeed
    User::SubmitIteration.(solution, files)
  end

end

