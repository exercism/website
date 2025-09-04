require "test_helper"

class DonationsMailerTest < ActionMailer::TestCase
  test "payment created" do
    user = create(:user, handle: "handle-6b48cf20")
    payment = create(:payments_payment, user:)

    email = DonationsMailer.with(payment:).payment_created

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [user.email], email.to
    assert_equal "Thank you for your donation", email.subject

    if email.html_part
      body_text =
        ActionView::Base.full_sanitizer.sanitize(email.html_part.body.to_s)
    elsif email.text_part
      body_text =
        email.text_part.body.to_s
    else
      body_text =
        ActionView::Base.full_sanitizer.sanitize(email.body.to_s)
    end

    normalized = body_text.gsub(/\s+/, " ").strip

    assert_includes normalized,
      "Thank you for your donation! Exercism exists to bring the joy of programming to everyone, everywhere. Your donation helps make everything we do possible." # rubocop:disable Layout/LineLength
    assert_includes normalized, "View your donations"
  end
end
