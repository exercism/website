require "test_helper"

class MailshotTest < ActiveSupport::TestCase
  test "custom_mailer? is true for custom mailer slugs" do
    assert create(:mailshot, slug: "jiki_launch").custom_mailer?
  end

  test "custom_mailer? is false for normal slugs" do
    refute create(:mailshot, slug: "some_normal_mailshot").custom_mailer?
  end

  test "custom mailer requires an email_communication_preferences_key" do
    mailshot = build(:mailshot, slug: "jiki_launch", email_communication_preferences_key: nil)

    refute mailshot.valid?
    assert_includes mailshot.errors[:email_communication_preferences_key], "can't be blank"
  end

  test "normal mailshot allows a blank email_communication_preferences_key" do
    assert build(:mailshot, slug: "some_normal_mailshot", email_communication_preferences_key: nil).valid?
  end
end
