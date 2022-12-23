require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Mentor
    class SupermentorGivesFeedbackToRepresentationTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "mentor sees only supermentor frequency tracks on need feedback page" do
        mentor = create :user, :supermentor

        csharp = create :track, slug: :csharp, title: 'C#'
        ruby = create :track, slug: :ruby, title: 'Ruby'
        javascript = create :track, slug: :javascript, title: 'JavaScript'

        csharp_exercise = create :practice_exercise, track: csharp
        ruby_exercise = create :practice_exercise, track: ruby
        create :practice_exercise, track: javascript

        create :exercise_representation, exercise: csharp_exercise, feedback_type: nil, num_submissions: 3
        create :exercise_representation, exercise: ruby_exercise, feedback_type: nil, num_submissions: 2

        create :user_track_mentorship, :supermentor_frequency, user: mentor, track: csharp
        create :user_track_mentorship, user: mentor, track: javascript
        create :user_track_mentorship, :supermentor_frequency, user: mentor, track: ruby

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_automation_index_path

          within(".automation-header") do
            click_on "C#"

            assert_text csharp.title
            assert_text ruby.title
            refute_text javascript.title
          end
        end
      end
    end
  end
end
