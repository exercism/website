require "test_helper"

class Exercise::ExportSolutionsToZipFileTest < ActiveSupport::TestCase
  test "export exercise without solutions" do
    exercise = create :practice_exercise

    zip_file_stream = Exercise::ExportSolutionsToZipFile.(exercise)

    Zip::File.open_buffer(zip_file_stream) do |zip_file|
      assert_empty zip_file.to_a
    end
  end

  test "exports solutions in zip format" do
    num_solutions = 5
    exercise = create :practice_exercise

    num_solutions.times do |idx|
      iteration = create :iteration, exercise: exercise
      create :submission_file, submission: iteration.submission, filename: "stub.rb", content: "Stub #{idx}"
    end

    zip_file_stream = Exercise::ExportSolutionsToZipFile.(exercise)

    Zip::File.open_buffer(zip_file_stream) do |zip_file|
      num_solutions.times do |idx|
        assert_equal "Stub #{idx}", zip_file.read("#{idx}/stub.rb")
      end
    end
  end

  test "exports last 500 solutions" do
    exercise = create :practice_exercise

    501.times do |idx|
      iteration = create :iteration, exercise: exercise
      create :submission_file, submission: iteration.submission, filename: "stub.rb", content: "Stub #{idx}"
    end

    zip_file_stream = Exercise::ExportSolutionsToZipFile.(exercise)

    Zip::File.open_buffer(zip_file_stream) do |zip_file|
      assert_equal 500, zip_file.size
      assert_equal "Stub 1", zip_file.read("0/stub.rb")
      assert_equal "Stub 500", zip_file.read("499/stub.rb")
    end
  end

  test "supports solution files in nested directory" do
    iteration = create :iteration
    create :submission_file, submission: iteration.submission, filename: "src/stub.rb", content: "Stub"

    zip_file_stream = Exercise::ExportSolutionsToZipFile.(iteration.exercise)

    Zip::File.open_buffer(zip_file_stream) do |zip_file|
      assert_equal "Stub", zip_file.read("0/src/stub.rb")
    end
  end

  test "supports multiple solution files" do
    iteration = create :iteration
    create :submission_file, submission: iteration.submission, filename: "src/stub.rb", content: "Stub"
    create :submission_file, submission: iteration.submission, filename: "test/test.rb", content: "Test"
    create :submission_file, submission: iteration.submission, filename: "helper.rb", content: "Helper"

    zip_file_stream = Exercise::ExportSolutionsToZipFile.(iteration.exercise)

    Zip::File.open_buffer(zip_file_stream) do |zip_file|
      assert_equal "Stub", zip_file.read("0/src/stub.rb")
      assert_equal "Test", zip_file.read("0/test/test.rb")
      assert_equal "Helper", zip_file.read("0/helper.rb")
    end
  end

  test "uses first iteration's files" do
    solution = create :practice_solution
    iteration_1 = create :iteration, solution: solution, idx: 1
    iteration_2 = create :iteration, solution: solution, idx: 2
    create :submission_file, submission: iteration_1.submission, filename: "src/stub.rb", content: "Stub v1"
    create :submission_file, submission: iteration_2.submission, filename: "src/stub.rb", content: "Stub v2"
    zip_file_stream = Exercise::ExportSolutionsToZipFile.(solution.reload.exercise)

    Zip::File.open_buffer(zip_file_stream) do |zip_file|
      assert_equal "Stub v1", zip_file.read("0/src/stub.rb")
    end
  end
end
