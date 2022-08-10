require "test_helper"

class Exercise::ExportSolutionsToZipFileTest < ActiveSupport::TestCase
  test "exercise without solutions" do
    exercise = create :practice_exercise

    zip_file_path = Exercise::ExportSolutionsToZipFile.(exercise)

    assert File.exist?(zip_file_path)
    Zip::File.open(zip_file_path) do |zip_file|
      assert_empty zip_file.to_a
    end
  end

  test "exports solutions in correct zip format" do
    num_solutions = 5
    exercise = create :practice_exercise

    num_solutions.times do |idx|
      iteration = create :iteration, exercise: exercise
      create :submission_file, submission: iteration.submission, filename: "stub.rb", content: "Stub #{idx}"
    end

    zip_file_path = Exercise::ExportSolutionsToZipFile.(exercise)

    assert File.exist?(zip_file_path)
    Zip::File.open(zip_file_path) do |zip_file|
      num_solutions.times do |idx|
        assert "Stub #{idx}", zip_file.read("#{idx}/stub.rb")
      end
    end
  end

  test "supports files that are not in exercise root" do
    iteration = create :iteration
    create :submission_file, submission: iteration.submission, filename: "src/stub.rb", content: "Stub"

    zip_file_path = Exercise::ExportSolutionsToZipFile.(iteration.exercise)

    assert File.exist?(zip_file_path)
    Zip::File.open(zip_file_path) do |zip_file|
      assert "Stub", zip_file.read("0/src/stub.rb")
    end
  end
end
