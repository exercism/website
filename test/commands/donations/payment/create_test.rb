require_relative '../test_base'

class Donations::Payment::CreateTest < Donations::TestBase
  test "creates correctly" do
    user = create :user
    id = SecureRandom.uuid
    amount = 1500
    receipt_url = SecureRandom.uuid
    data = mock_stripe_payment(id, amount, receipt_url)

    Donations::Payment::Create.(user, data)

    assert_equal 1, Donations::Payment.count

    payment = Donations::Payment.last
    assert_equal id, payment.stripe_id
    assert_equal amount, payment.amount_in_cents
    assert_equal receipt_url, payment.stripe_receipt_url
    assert_equal user, payment.user
    assert_nil payment.subscription
    assert_equal amount, user.total_donated_in_cents
    assert user.donated
  end

  test "awards supporter badge" do
    user = create :user
    refute user.reload.badges.present?

    assert_enqueued_with(job: AwardBadgeJob) do
      Donations::Payment::Create.(user, mock_stripe_payment(1, 1, ""))
    end

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::SupporterBadge
  end

  test "sends email" do
    user = create :user

    perform_enqueued_jobs do
      Donations::Payment::Create.(user, mock_stripe_payment(1, 1, ""))
    end

    deliveries = ActionMailer::Base.deliveries.select { |d| d.subject == "Thank you for your donation" }
    assert_equal 1, deliveries.count
    assert_equal [user.email], deliveries.first.to
  end

  test "works with subscription passed manually" do
    user = create :user
    subscription = create :donations_subscription
    data = mock_stripe_payment(5, 1500, "")

    Donations::Payment::Create.(user, data, subscription:)

    assert_equal 1, Donations::Payment.count

    payment = Donations::Payment.last
    assert_equal subscription, payment.subscription
  end

  test "works with subscription from invoice" do
    invoice_id = SecureRandom.uuid
    stripe_subscription_id = SecureRandom.uuid
    user = create :user
    subscription = create :donations_subscription, user: user, stripe_id: stripe_subscription_id
    data = mock_stripe_payment(5, 1500, "", invoice_id:)

    invoice = mock_stripe_invoice(nil, stripe_subscription_id)
    Stripe::Invoice.expects(:retrieve).with(invoice_id).returns(invoice)

    Donations::Payment::Create.(user, data)

    assert_equal 1, Donations::Payment.count

    payment = Donations::Payment.last
    assert_equal subscription, payment.subscription
  end

  test "raises if subscription isn't set up yet" do
    invoice_id = SecureRandom.uuid
    user = create :user
    data = mock_stripe_payment(5, 1500, "", invoice_id:)

    invoice = mock_stripe_invoice(nil, SecureRandom.uuid)
    Stripe::Invoice.expects(:retrieve).with(invoice_id).returns(invoice)

    assert_raises Donations::Payment::Create::SubscriptionNotCreatedError do
      Donations::Payment::Create.(user, data)
    end
  end

  test "idempotent" do
    user = create :user
    id = SecureRandom.uuid
    amount = 1500
    data = mock_stripe_payment(id, amount, "")

    payment_1 = Donations::Payment::Create.(user, data)
    payment_2 = Donations::Payment::Create.(user, data)

    assert_equal 1, Donations::Payment.count
    assert_equal payment_1, payment_2
  end
end
