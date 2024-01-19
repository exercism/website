require "application_system_test_case"
require_relative "../../../support/capybara_helpers"
require_relative "../../../support/uri_encode_helpers"

module Flows
  module Blog
    class UserViewsAuthorProfileTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "clicking on public blog author opens author profile page" do
        user = create :user
        create(:user_profile, user:)
        post = create :blog_post, author: user

        use_capybara_host do
          visit blog_post_path(post)
          assert_text user.name
          click_on user.name
          assert_current_path profile_path(user)
        end
      end

      test "clicking on private blog author does not navigate to profile page" do
        user = create :user
        post = create :blog_post, author: user

        use_capybara_host do
          visit blog_post_path(post)
          assert_text user.name
          click_on user.name
          refute_current_path profile_path(user)
        end
      end
    end
  end
end
