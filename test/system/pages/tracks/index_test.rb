require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Pages
  module Tracks
    class IndexTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "index: params get passed correctly" do
        ruby_1 = create :track, slug: :ruby_1, title: "Ruby #{SecureRandom.hex}"
        js = create :track, slug: :js, title: "JS #{SecureRandom.hex}"
        ruby_2 = create :track, slug: :ruby_2, title: "Ruby #{SecureRandom.hex}"

        user = create :user
        create :user_track, user:, track: ruby_1
        create :user_track, user:, track: js

        use_capybara_host do
          sign_in!(user)

          visit tracks_url(
            criteria: "ruby",
            status: "joined"
          )

          # Assert only the track that matches the criteria
          # is retrieved and served.
          within ".c-tracks-list" do
            assert_text ruby_1.title
            refute_text js.title
            refute_text ruby_2.title
          end
        end
      end
    end
  end
end
