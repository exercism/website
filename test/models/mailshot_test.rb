require "test_helper"

class MailshotTest < ActiveSupport::TestCase
  test "custom_mailer? is true for custom mailer slugs" do
    assert create(:mailshot, slug: "jiki_launch").custom_mailer?
  end

  test "custom_mailer? is false for normal slugs" do
    refute create(:mailshot, slug: "some_normal_mailshot").custom_mailer?
  end
end
