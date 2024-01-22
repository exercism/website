require "application_system_test_case"
require_relative "../../../support/capybara_helpers"
require_relative "../../../support/uri_encode_helpers"

module Flows
  module Blog
    class UserViewsAuthorProfileTest < ApplicationSystemTestCase
      include CapybaraHelpers

      setup do
        @user = create :user
        @post = create :blog_post, author: @user
      end

      test "author with profile is linked" do
        create(:user_profile, user: @user)

        use_capybara_host do
          visit blog_post_path(@post)
          assert_selector 'a.byline', text: @user.name
          find('a.byline', text: @user.name).click
          assert_current_path profile_path(@user)
        end
      end

      test "author without profile is not linked" do
        use_capybara_host do
          visit blog_post_path(@post)
          assert_selector 'div.byline', text: @user.name
          find('div.byline', text: @user.name).click
          refute_current_path profile_path(@user)
        end
      end
    end
  end
end
