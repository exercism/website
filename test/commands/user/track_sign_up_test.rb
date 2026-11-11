require "test_helper"

class User::TrackSignUpTest < ActiveSupport::TestCase
  test "sends user_signed_up with the attribution mapped onto PostHog's properties" do
    user = create :user, provider: "github"
    attribution = {
      "referrer" => "https://www.google.com/search",
      "landing_path" => "/tracks/ruby",
      "utm_source" => "newsletter",
      "utm_medium" => "email",
      "utm_campaign" => "launch",
      "utm_content" => "button"
    }
    landing_url = URI.join(Exercism::Routes.root_url, "/tracks/ruby").to_s

    Analytics::TrackEvent.expects(:defer).with(
      user,
      "user_signed_up",
      properties: {
        provider: "github",
        referrer: "https://www.google.com/search",
        landing_path: "/tracks/ruby",
        utm_source: "newsletter",
        utm_medium: "email",
        utm_campaign: "launch",
        utm_content: "button",
        "$referrer": "https://www.google.com/search",
        "$referring_domain": "www.google.com",
        "$current_url": landing_url,
        "$set": Analytics::IdentifyUser.person_properties(user),
        "$set_once": {
          "$initial_referrer": "https://www.google.com/search",
          "$initial_referring_domain": "www.google.com",
          "$initial_current_url": landing_url,
          "$initial_utm_source": "newsletter",
          "$initial_utm_medium": "email",
          "$initial_utm_campaign": "launch",
          "$initial_utm_content": "button"
        }
      }
    )

    User::TrackSignUp.(user, attribution:)
  end

  test "treats a signup without attribution as direct" do
    user = create :user, provider: nil

    Analytics::TrackEvent.expects(:defer).with(
      user,
      "user_signed_up",
      properties: {
        provider: "email",
        "$referrer": "$direct",
        "$referring_domain": "$direct",
        "$set": Analytics::IdentifyUser.person_properties(user),
        "$set_once": {
          "$initial_referrer": "$direct",
          "$initial_referring_domain": "$direct"
        }
      }
    )

    User::TrackSignUp.(user)
  end

  test "ignores a landing path that isn't a path on this site" do
    user = create :user

    Analytics::TrackEvent.expects(:defer).with do |_user, _event, properties:|
      !properties.key?(:"$current_url")
    end

    User::TrackSignUp.(user, attribution: { "landing_path" => "//evil.example/" })
  end
end
