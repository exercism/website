require 'test_helper'

class Iteration::CreateTest < ActiveSupport::TestCase
  test "creates iteration in the database" do
    filename_1 = "subdir/foobar.rb"
    content_1 = "'I think' = 'I am'"
    digest_1 = Digest::SHA1.hexdigest(content_1)

    filename_2 = "barfood.rb"
    content_2 = "something = :else"
    digest_2 = Digest::SHA1.hexdigest(content_2)
 
    files = [
      { filename: filename_1, content: content_1 },
      { filename: filename_2, content: content_2 }
    ]

    Iteration::UploadWithExercise.expects(:call)
    Iteration::UploadForStorage.expects(:call)
    Iteration::TestRun::Init.expects(:call)
    Iteration::Analysis::Init.expects(:call)
    Iteration::Representation::Init.expects(:call)

    solution = create :concept_solution
    iteration = Iteration::Create.(solution, files, :cli)

    assert iteration.persisted?
    assert_equal iteration.solution, solution
    assert_equal 2, iteration.files.count

    first_file = iteration.files.first
    assert_equal filename_1, first_file.filename
    assert_equal digest_1, first_file.digest

    second_file = iteration.files.last
    assert_equal filename_2, second_file.filename
    assert_equal digest_2, second_file.digest
  end

  test "guards against duplicates" do
    solution = create :concept_solution
    filename_1 = "subdir/foobar.rb"
    content_1 = "'I think' = 'I am'"

    filename_2 = "barfood.rb"
    content_2 = "something = :else"
 
    files = [
      { filename: filename_1, content: content_1 },
      { filename: filename_2, content: content_2 }
    ]

    # We'll call upload so stub it
    Iteration::UploadWithExercise.stubs(:call)
    Iteration::UploadForStorage.stubs(:call)

    # Do it once successfully
    Iteration::Create.(solution, files, :cli)

    # The second time *in a row* it should fail
    assert_raises DuplicateIterationError do
      Iteration::Create.(solution, files, :cli)
    end

    # Submit something different
    Iteration::Create.(solution, [files.first], :cli)

    # The duplicate should now succeed
    Iteration::Create.(solution, files, :cli)
  end

  test "updates solution status" do
    files = [{ filename: 'foo.bar', content: "foobar" }]

    solution = create :concept_solution
    assert_equal 'pending', solution.status
    assert solution.pending?

    Iteration::UploadWithExercise.stubs(:call)
    Iteration::UploadForStorage.stubs(:call)
    Iteration::Create.(solution, [files.first], :cli)
    assert_equal 'submitted', solution.reload.status
  end
end
