require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Maintainer
    class MaintainerExportsSolutionsTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "maintainer exports solutions" do
        skip # TODO: Readd this

        maintainer = create :user, :maintainer
        iteration = create :iteration
        create :submission_file, submission: iteration.submission, filename: "src/stub.rb", content: "Stub"

        solutions_zip_file = TestHelpers.download_filepath('solutions.zip')
        FileUtils.rm_f(solutions_zip_file)

        use_capybara_host do
          sign_in!(maintainer)
          visit api_track_exercise_export_solutions_path(iteration.track.slug, iteration.exercise.slug)

          Zip::File.open(solutions_zip_file) do |zip_file|
            assert_equal "Stub", zip_file.read("0/src/stub.rb")
          end
        end
      end
    end
  end
end
