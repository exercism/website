require "test_helper"

class Exercise::ExportSolutionsToZipFileTest < ActiveSupport::TestCase
  test "exercise without solutions" do
    exercise = create :practice_exercise
    zip_file = Exercise::ExportSolutionsToZipFile.(exercise)

    assert File.exist?(zip_file)
  end
end
