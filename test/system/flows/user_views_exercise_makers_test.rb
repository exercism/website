require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class UserViewsExerciseMakersTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "user views exercise contributors" do
      user = create :user
      author = create :user, handle: "ExerciseAuthor"
      exercise = create :concept_exercise
      create(:exercise_authorship, exercise:, author:)

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_path(exercise.track, exercise)
        click_on "1 author"

        assert_text "ExerciseAuthor"
      end
    end
  end
end
