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
      iteration = create(:iteration, exercise:)
      create :submission_file, submission: iteration.submission, filename: "stub.rb", content: "Stub #{idx}"
    end

    zip_file_stream = Exercise::ExportSolutionsToZipFile.(exercise)

    Zip::File.open_buffer(zip_file_stream) do |zip_file|
      num_solutions.times do |idx|
        assert_equal "Stub #{idx}", zip_file.read("#{idx}/stub.rb")
      end
    end
  end

  test "only exports iterations" do
    exercise = create :practice_exercise
    solution_1 = create(:practice_solution, exercise:)
    iteration = create :iteration, solution: solution_1
    create :submission_file, submission: iteration.submission, filename: "stub.rb", content: "Stub 1"

    solution_2 = create :practice_solution
    submission = create :submission, solution: solution_2
    create :submission_file, submission:, filename: "stub.rb", content: "Stub 2"

    zip_file_stream = Exercise::ExportSolutionsToZipFile.(exercise)

    Zip::File.open_buffer(zip_file_stream) do |zip_file|
      assert_equal "Stub 1", zip_file.read("0/stub.rb")
      refute zip_file.find_entry("1/stub.rb")
    end
  end

  test "only exports last x solutions" do
    exercise = create :practice_exercise

    num_submissions = 5
    Exercise::ExportSolutionsToZipFile.stubs(num_submissions:)

    (num_submissions + 1).times do |idx|
      iteration = create(:iteration, exercise:)
      create :submission_file, submission: iteration.submission, filename: "stub.rb", content: "Stub #{idx}"
    end

    zip_file_stream = Exercise::ExportSolutionsToZipFile.(exercise)

    Zip::File.open_buffer(zip_file_stream) do |zip_file|
      assert_equal "Stub 1", zip_file.read("0/stub.rb")
      assert_equal "Stub #{num_submissions}", zip_file.read("#{num_submissions - 1}/stub.rb")
      refute zip_file.find_entry("#{num_submissions}/stub.rb")
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
    submission_1 = create(:submission, solution:)
    submission_2 = create(:submission, solution:)
    create :iteration, solution:, idx: 1, submission: submission_1
    create :iteration, solution:, idx: 2, submission: submission_2
    create :submission_file, submission: submission_1, filename: "src/stub.rb", content: "Stub v1"
    create :submission_file, submission: submission_2, filename: "src/stub.rb", content: "Stub v2"
    zip_file_stream = Exercise::ExportSolutionsToZipFile.(solution.reload.exercise)

    Zip::File.open_buffer(zip_file_stream) do |zip_file|
      assert_equal "Stub v1", zip_file.read("0/src/stub.rb")
    end
  end

  test "includes exercise files" do
    exercise = create :practice_exercise, slug: 'hamming'
    solution = create(:practice_solution, exercise:)
    submission = create(:submission, solution:)
    iteration = create(:iteration, submission:)
    create :submission_file, submission:, filename: "log_line_parser.rb", content: "Impl"

    zip_file_stream = Exercise::ExportSolutionsToZipFile.(iteration.exercise)

    Zip::File.open_buffer(zip_file_stream) do |zip_file|
      assert_equal "Impl", zip_file.read("0/log_line_parser.rb")
      assert_equal "AllCops:\n  NewCops: disable\n", zip_file.read("0/rubocop.yml")
      assert_equal "example content for hamming\n", zip_file.read("0/.meta/example.rb")
      assert zip_file.find_entry("0/.meta/config.json")
    end
  end
end
