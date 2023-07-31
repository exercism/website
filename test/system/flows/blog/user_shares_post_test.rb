require "application_system_test_case"
require_relative "../../../support/capybara_helpers"
require_relative "../../../support/uri_encode_helpers"

module Flows
  module Blog
    class UserSharesPostTest < ApplicationSystemTestCase
      include CapybaraHelpers
      include UriEncodeHelpers

      test "user sees share panel upon clicking share button" do
        Exercism.stubs(:share_platforms).returns([:twitter])
        post = create :blog_post

        use_capybara_host do
          visit blog_post_path(post)
          click_on "Share"

          assert_link(
            "Twitter",
            href: uri_encode("https://twitter.com/intent/tweet?url=#{blog_post_url(post)}&title=#{post.title}")
          )
          assert_button blog_post_url(post)
        end
      end

      test "user sees share panel upon clicking share link" do
        Exercism.stubs(:share_platforms).returns([:twitter])
        post = create :blog_post

        use_capybara_host do
          visit blog_post_path(post)
          click_on "Share it."

          assert_link(
            "Twitter",
            href: uri_encode("https://twitter.com/intent/tweet?url=#{blog_post_url(post)}&title=#{post.title}")
          )
          assert_button blog_post_url(post)
        end
      end
    end
  end
end
