require "test_helper"

class DonationsMailerTest < ActionMailer::TestCase
  test "payment created" do
    user = create :user, handle: "handle-6b48cf20"
    payment = create(:payments_payment, user:)

    email = DonationsMailer.with(payment:).payment_created
    subject = "Thank you for your donation"
    assert_email(email, user.email, subject, "payment_created")
  end
end
