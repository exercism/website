require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Settings
    class UserVisitsInsidersSettingsTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "user is not an insider" do
        user = create :user, insiders_status: :ineligible

        use_capybara_host do
          sign_in!(user)

          visit insiders_settings_path
          sleep(5)

          assert_text "Donate to Exercism"

          links = all("a", text: "Donate to Exercism")
          assert_equal 2, links.size, "Expected exactly 2 'Donate to Exercism' links but found #{links.size}"

          expected_hrefs = [Exercism::Routes.insiders_url, Exercism::Routes.insiders_url]

          links.each_with_index do |link, index|
            assert_equal expected_hrefs[index], link[:href], "Link #{index + 1} href does not match"
          end

          change_button = find("button", text: "Change preferences")
          assert change_button[:disabled]

          assert_text "Bootcamp Affiliate Coupon"
          generate_button = find("#generate-affiliate-coupon-code-button", text: "Click to generate code")
          assert generate_button[:disabled]
          refute_text "Bootcamp Free Coupon"
        end
      end
      test "user is eligible" do
        user = create :user, insiders_status: :eligible

        use_capybara_host do
          sign_in!(user)

          visit insiders_settings_path
          sleep(2)

          refute_text "Bootcamp Free Coupon"
          assert_text "You're eligible to join Insiders"
          change_button = find("button", text: "Change preferences")
          assert change_button[:disabled]

          assert_text "Bootcamp Affiliate Coupon"
          generate_button = find("button", text: "Click to generate code")
          assert generate_button[:disabled]
        end
      end

      test "user is insider" do
        user = create :user, insiders_status: :active

        use_capybara_host do
          sign_in!(user)

          visit insiders_settings_path
          sleep(2)

          assert_text "These are exclusive options"
          assert_text "You've not yet generated your affiliate code"

          assert_text "Bootcamp Affiliate Coupon"

          assert has_no_css?("button[disabled]", text: "Change preferences"),
            "Change preference button should be enabled but it is disabled"
          assert has_no_css?("button[disabled]", text: "Click to generate code"),
            "Generate button should be enabled but it is disabled"
          assert_button("Change preferences")
          assert_button("Click to generate code")

          refute_text "Bootcamp Free Coupon"
        end
      end

      test "user is lifetime insider" do
        user = create :user, insiders_status: :active_lifetime

        use_capybara_host do
          sign_in!(user)

          visit insiders_settings_path
          sleep(2)

          assert_text "These are exclusive options"
          assert_text "You've not yet generated your affiliate code"

          assert_text "Bootcamp Affiliate Coupon"

          assert has_no_css?("button[disabled]", text: "Change preferences"),
            "Change preference button should be enabled but it is disabled"
          assert has_no_css?("button[disabled]", text: "Click to generate code"),
            "Generate button should be enabled but it is disabled"
          assert_button("Change preferences")
          assert_button("Click to generate code")

          assert_text "Bootcamp Free Coupon"
        end
      end

      test "user changes hide adverts successfully" do
        user = create :user, insiders_status: :active_lifetime
        use_capybara_host do
          sign_in!(user)

          visit insiders_settings_path
          sleep(2)

          find(:xpath, "//*[text()='Hide website adverts']").click
          click_on "Change preferences"
          assert_text "Your preferences have been updated"
        end
      end

      test "user generates code successfully" do
        user = create :user, insiders_status: :active_lifetime

        stub_request(:post, "https://api.stripe.com/v1/promotion_codes").
          with(body: { "coupon" => "NRp5SOVV", "metadata" => { "user_id" => "37" } }).
          to_return(status: 200, body: { coupon_code: 'test_code' }.to_json, headers: {})

        use_capybara_host do
          sign_in!(user)

          visit insiders_settings_path
          sleep(2)

          find("#generate-affiliate-coupon-code-button").click
          assert_text "test_code"
        end
      end
    end
  end
end