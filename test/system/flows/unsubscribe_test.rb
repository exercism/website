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
    assert_text I18n.t('communication_preferences.email_on_mentor_started_discussion_notification')
    click_on "Unsubscribe from email"
    assert_text "You have been unsubscribed successfully"

    refute preferences.reload.email_on_mentor_started_discussion_notification
  end

  test "user unsubscribes using form if logged in" do
    user = create :user
    preferences = user.communication_preferences
    assert preferences.email_on_mentor_started_discussion_notification
    assert preferences.receive_product_updates

    use_capybara_host do
      sign_in!(user)
      visit unsubscribe_path(token: preferences.token, key: 'email_on_mentor_started_discussion_notification')
      find('label', text: I18n.t('communication_preferences.email_on_mentor_started_discussion_notification')).click
      click_on "Change preferences"
      assert_text "Your preferences have been updated"
    end

    refute preferences.reload.email_on_mentor_started_discussion_notification
    assert preferences.receive_product_updates
  end

  test "user unsubscribes using email key" do
    user = create :user
    preferences = create(:user_communication_preferences, user:)
    assert preferences.email_on_mentor_started_discussion_notification
    assert preferences.receive_product_updates

    use_capybara_host do
      visit unsubscribe_path(token: preferences.token, key: 'email_on_mentor_started_discussion_notification')
      click_on "Unsubscribe from email"
      assert_text "You have been unsubscribed successfully"
    end

    refute preferences.reload.email_on_mentor_started_discussion_notification
    assert preferences.receive_product_updates
  end

  test "user unsubscribes from all emails" do
    preferences = create(:user_communication_preferences)
    assert preferences.email_on_mentor_started_discussion_notification
    assert preferences.receive_product_updates

    use_capybara_host do
      visit unsubscribe_path(token: preferences.token, key: 'email_on_mentor_started_discussion_notification')
      click_on "Unsubscribe from all emails"
      assert_text "You have been unsubscribed from all emails successfully"
    end

    refute preferences.reload.email_on_mentor_started_discussion_notification
    refute preferences.receive_product_updates
  end
end
