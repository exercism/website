require "test_helper"

class User::ParseSignupAttributionTest < ActiveSupport::TestCase
  test "keeps the known fields" do
    raw = {
      referrer: "https://www.google.com/",
      landing_path: "/tracks/ruby",
      utm_source: "newsletter",
      utm_medium: "email",
      utm_campaign: "launch",
      utm_content: "button"
    }.to_json

    assert_equal(
      {
        "referrer" => "https://www.google.com/",
        "landing_path" => "/tracks/ruby",
        "utm_source" => "newsletter",
        "utm_medium" => "email",
        "utm_campaign" => "launch",
        "utm_content" => "button"
      },
      User::ParseSignupAttribution.(raw)
    )
  end

  test "drops unknown fields, values that aren't strings and empty values" do
    raw = { landing_path: "/", utm_source: "", utm_medium: { a: 1 }, utm_campaign: 3, token: "secret" }.to_json

    assert_equal({ "landing_path" => "/" }, User::ParseSignupAttribution.(raw))
  end

  test "truncates long values" do
    raw = { utm_source: "a" * 500 }.to_json

    assert_equal 200, User::ParseSignupAttribution.(raw)["utm_source"].length
  end

  test "returns an empty hash for a missing or invalid cookie" do
    assert_empty User::ParseSignupAttribution.(nil)
    assert_empty User::ParseSignupAttribution.("")
    assert_empty User::ParseSignupAttribution.("not json")
    assert_empty User::ParseSignupAttribution.("[1, 2]")
  end
end
