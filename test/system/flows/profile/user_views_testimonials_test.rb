require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Profile
    class UserViewsTestimonialsTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "shows testimonials for a user" do
        # TODO: Change this stub
        User::Profile.any_instance.expects(testimonials_tab?: true).at_least_once
        user = create :user, handle: "author"
        create(:user_profile, user:)
        create :mentor_testimonial, mentor: user, revealed: true, content: "Best mentor!"
        create :mentor_testimonial, mentor: user, revealed: false, content: "Good mentor!"

        use_capybara_host do
          visit testimonials_profile_url(user.handle)

          assert_no_text "Good mentor!"
          assert_text "Best mentor!"
        end
      end

      test "shows testimonial for a user" do
        User::Profile.any_instance.expects(testimonials_tab?: true).at_least_once
        user = create :user, handle: "author"
        create(:user_profile, user:)
        testimonial = create :mentor_testimonial, mentor: user, revealed: true, content: "Best mentor!"

        use_capybara_host do
          visit testimonials_profile_url(user.handle, uuid: testimonial.uuid)

          within(".m-testimonial") { assert_text "Best mentor!" }
        end
      end
    end
  end
end
