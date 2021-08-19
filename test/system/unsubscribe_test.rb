require "application_system_test_case"

class UnsubscribeTest < ApplicationSystemTestCase
  test "redirects with missing token" do
    visit unsubscribe_path(token: nil)
    assert_selector "#page-auth"
  end

  test "redirects with invalid token" do
    visit unsubscribe_path(token: "meh")
    assert_selector "#page-auth"
  end

  test "user unsubscribes using button" do
    preferences = create :user_communication_preferences, token: SecureRandom.uuid
    assert preferences.email_on_mentor_started_discussion_notification

    visit unsubscribe_path(token: preferences.token, key: 'email_on_mentor_started_discussion_notification')
    click_on "Unsubscribe from 'Email me with weekly mentor summaries'"
    assert_selector "#notice", text: "Your communication Preferences have been updated successfully"

    refute preferences.reload.email_on_mentor_started_discussion_notification
  end

  test "user unsubscribes using form" do
    preferences = create :user_communication_preferences, token: SecureRandom.uuid
    assert preferences.email_on_mentor_started_discussion_notification

    visit unsubscribe_path(token: preferences.token, key: 'email_on_mentor_started_discussion_notification')
    click_on "Email me with weekly mentor summaries"
    click_on "Update preferences"
    assert_selector "#notice", text: "Your communication Preferences have been updated successfully"

    refute preferences.reload.email_on_mentor_started_discussion_notification
  end
end
