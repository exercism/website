require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Pages
  module Tracks
    class IndexTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "index: params get passed correctly" do
        ruby = create :track, slug: "ruby", title: "Ruby #{SecureRandom.hex}"
        js = create :track, slug: "javascript", title: "JS #{SecureRandom.hex}"

        user = create :user
        create :user_track, user:, track: ruby
        create :user_track, user:, track: js

        use_capybara_host do
          sign_in!(user)

          visit tracks_url(
            criteria: "ruby",
            status: "joined"
          )

          # Assert only the track that matches the criteria
          # is retrieved and served.
          within ".tracks-list" do
            assert_text ruby.title
            refute_text js.title
          end
        end
      end
    end
  end
end
