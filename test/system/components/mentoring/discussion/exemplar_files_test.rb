require "application_system_test_case"
require_relative "../../../../support/capybara_helpers"

module Components
  module Mentoring
    module Discussion
      class ExemplarFilesTest < ApplicationSystemTestCase
        include CapybaraHelpers

        test "mentor sees exemplar files" do
          mentor = create :user
          exercise = create :concept_exercise, slug: "log-levels"
          solution = create(:concept_solution, exercise:)
          discussion = create(:mentor_discussion, solution:, mentor:)
          submission = create(:submission, solution:)
          create(:iteration, solution:, submission:)

          use_capybara_host do
            sign_in!(mentor)
            visit mentoring_discussion_path(discussion)
            click_on "Guidance"

            exercise.exemplar_files.each do |filename, content|
              assert_text filename.gsub(%r{^\.meta/}, '')
              assert_text content, normalize_ws: false
            end
          end
        end

        test "mentor does not see exemplar files section if exemplar files are empty" do
          mentor = create :user
          exercise = create :practice_exercise, slug: "allergies"
          solution = create(:practice_solution, exercise:)
          discussion = create(:mentor_discussion, solution:, mentor:)
          submission = create(:submission, solution:)
          create(:iteration, solution:, submission:)

          use_capybara_host do
            sign_in!(mentor)
            visit mentoring_discussion_path(discussion)
            click_on "Guidance"

            assert_no_text "The exemplar solution"
          end
        end
      end
    end
  end
end
