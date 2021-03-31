require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class UserViewsPublishedSolutionsTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "shows published solutions" do
      author = create :user, handle: "author"
      create :user_profile, user: author
      ruby = create :track, title: "Ruby"
      exercise = create :concept_exercise, track: ruby, title: "Strings"
      solution = create :concept_solution, exercise: exercise, published_at: 2.days.ago, user: author
      submission = create :submission, solution: solution
      create :iteration, solution: solution, submission: submission

      use_capybara_host do
        sign_in!(author)
        visit profile_path(author.handle)
      end

      assert_text "author's solution"
    end
  end
end
