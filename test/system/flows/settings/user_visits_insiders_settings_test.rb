# require "application_system_test_case"
# require_relative "../../../support/capybara_helpers"
#
# module Flows
#   module Settings
#     class UserVisitsInsidersSettingsTest < ApplicationSystemTestCase
#       include CapybaraHelpers
#       FREE_BOOTCAMP_CANARY = "Free Seat on the Bootcamp".freeze
#
#       test "user is not an insider" do
#         user = create :user, insiders_status: :ineligible
#
#         use_capybara_host do
#           sign_in!(user)
#
#           visit insiders_settings_path
#           sleep(5)
#
#           assert_text "Donate to Exercism"
#
#           links = all("a", text: "Donate to Exercism")
#           assert_equal 1, links.size, "Expected exactly 1 'Donate to Exercism' links but found #{links.size}"
#
#           expected_hrefs = [Exercism::Routes.insiders_url, Exercism::Routes.insiders_url]
#
#           links.each_with_index do |link, index|
#             assert_equal expected_hrefs[index], link[:href], "Link #{index + 1} href does not match"
#           end
#
#           change_button = find("button", text: "Change preferences")
#           assert change_button[:disabled]
#
#           assert_text "Bootcamp Affiliate Coupon"
#           generate_button = find("#generate-affiliate-coupon-code-button", text: "Generate your Affiliate Discount code")
#           assert generate_button[:disabled]
#           refute_text FREE_BOOTCAMP_CANARY
#         end
#       end
#       test "user is eligible" do
#         user = create :user, insiders_status: :eligible
#
#         use_capybara_host do
#           sign_in!(user)
#
#           visit insiders_settings_path
#           sleep(2)
#
#           refute_text FREE_BOOTCAMP_CANARY
#           assert_text "You're eligible to join Insiders"
#           change_button = find("button", text: "Change preferences")
#           assert change_button[:disabled]
#
#           assert_text "Bootcamp Affiliate Coupon"
#           generate_button = find("button", text: "Generate your Affiliate Discount code")
#           assert generate_button[:disabled]
#         end
#       end
#
#       test "user is insider" do
#         user = create :user, insiders_status: :active
#
#         use_capybara_host do
#           sign_in!(user)
#
#           visit insiders_settings_path
#           sleep(2)
#
#           assert_text "we are giving all Insiders a Discount Affiliate code"
#
#           assert_text "Bootcamp Affiliate Coupon"
#
#           assert has_no_css?("button[disabled]", text: "Generate your Affiliate Discount code"),
#             "Change preference button should be enabled but it is disabled"
#           assert has_no_css?("button[disabled]", text: "Generate your Affiliate Discount code"),
#             "Generate button should be enabled but it is disabled"
#           assert_button("Change preferences")
#           assert_button("Generate your Affiliate Discount code")
#
#           refute_text FREE_BOOTCAMP_CANARY
#         end
#       end
#
#       test "user is lifetime insider" do
#         user = create :user, insiders_status: :active_lifetime
#
#         use_capybara_host do
#           sign_in!(user)
#
#           visit insiders_settings_path
#           sleep(2)
#
#           assert_text "we are giving all Insiders a Discount Affiliate code"
#
#           assert_text "Bootcamp Affiliate Coupon"
#
#           assert has_no_css?("button[disabled]", text: "Change preferences"),
#             "Change preference button should be enabled but it is disabled"
#           assert has_no_css?("button[disabled]", text: "Generate your Affiliate Discount code"),
#             "Generate button should be enabled but it is disabled"
#           assert_button("Change preferences")
#           assert_button("Generate your Affiliate Discount code")
#
#           assert_text FREE_BOOTCAMP_CANARY
#         end
#       end
#
#       test "user changes hide adverts successfully" do
#         user = create :user, insiders_status: :active_lifetime
#         use_capybara_host do
#           sign_in!(user)
#
#           visit insiders_settings_path
#           sleep(2)
#
#           find(:xpath, "//*[text()='Hide website adverts']").click
#           click_on "Change preferences"
#           assert_text "Your preferences have been updated"
#
#           visit insiders_settings_path
#           sleep(2)
#
#           user.reload
#           assert user.preferences.hide_website_adverts, "Failed to update user's hide_adverts preference"
#
#           checkbox = find("#insider-benefits-form input[type='checkbox']", visible: false)
#           assert checkbox.checked?, "Checkbox should be checked"
#         end
#       end
#
#       test "user generates code successfully" do
#         user = create :user, insiders_status: :active_lifetime
#         code = SecureRandom.hex(6)
#         Stripe::PromotionCode.expects(:create).returns(OpenStruct.new(code:))
#
#         use_capybara_host do
#           sign_in!(user)
#
#           visit insiders_settings_path
#           sleep(2)
#
#           find("#generate-affiliate-coupon-code-button").click
#           assert_text code
#         end
#       end
#     end
#   end
# end
