require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class DiscourseSsoTest < ApplicationSystemTestCase
    include ShowMeTheCookies
    include CapybaraHelpers

    test "user logs in and is redirected to forum" do
      track = create :track, title: "Ruby"
      create(:concept_exercise, track:)
      user = create(:user,
        email: "user@exercism.org",
        password: "password",
        confirmed_at: Date.new(2016, 12, 25))

      sso = mock
      sso.expects(:email=).with(user.email)
      sso.expects(:name=).with(user.name)
      sso.expects(:username=).with(user.handle)
      sso.expects(:external_id=).with(user.id)
      sso.expects(:avatar_url=).with(user.avatar_url)
      sso.expects(:bio=).with(user.bio)
      sso.expects(:sso_secret=).with(Exercism.secrets.discourse_oauth_secret)
      sso.expects(:to_url).returns(track_path(track))
      DiscourseApi::SingleSignOn.expects(:parse).with("key=value", Exercism.secrets.discourse_oauth_secret).returns(sso)

      use_capybara_host do
        visit discourse_sso_path(key: 'value')
        fill_in "Email", with: "user@exercism.org"
        fill_in "Password", with: "password"
        click_on "Log In"

        # Assert it's redirected at the end of the discouse SSO controller
        assert_text "Join the Ruby Track", wait: 10
      end
    end
  end
end
