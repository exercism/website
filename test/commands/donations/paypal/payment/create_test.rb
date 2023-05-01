require_relative '../../test_base'

class Donations::Paypal::Payment::CreateTest < Donations::TestBase
  test "creates correctly" do
    freeze_time do
      user = create :user
      paypal_payer_id = SecureRandom.uuid
      amount_in_dollars = 15
      amount_in_cents = 1500

      Donations::Paypal::Payment::Create.(user, paypal_payer_id, amount_in_dollars)

      assert_equal 1, Donations::Payment.count

      payment = Donations::Payment.last
      assert_equal paypal_payer_id, payment.external_id
      assert_equal amount_in_cents, payment.amount_in_cents
      assert_nil payment.external_receipt_url
      assert_equal user, payment.user
      assert_equal :paypal, payment.provider
      assert_nil payment.subscription
      assert_equal amount_in_cents, user.total_donated_in_cents
      assert_equal Time.current, user.first_donated_at
      assert user.donated?
    end
  end

  test "awards supporter badge" do
    user = create :user
    refute user.reload.badges.present?

    assert_enqueued_with(job: AwardBadgeJob) do
      Donations::Paypal::Payment::Create.(user, 1, 1)
    end

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::SupporterBadge
  end

  test "sends email" do
    user = create :user

    perform_enqueued_jobs do
      Donations::Paypal::Payment::Create.(user, 1, 1)
    end

    deliveries = ActionMailer::Base.deliveries.select { |d| d.subject == "Thank you for your donation" && d.to == [user.email] }
    assert_equal 1, deliveries.count
  end

  test "works with subscription passed manually" do
    user = create :user
    subscription = create :donations_subscription, provider: :paypal

    Donations::Paypal::Payment::Create.(user, 5, 1500, subscription:)

    assert_equal 1, Donations::Payment.count

    payment = Donations::Payment.last
    assert_equal subscription, payment.subscription
  end

  test "idempotent" do
    user = create :user
    id = SecureRandom.uuid
    amount_in_cents = 1500

    payment_1 = Donations::Paypal::Payment::Create.(user, id, amount_in_cents)
    payment_2 = Donations::Paypal::Payment::Create.(user, id, amount_in_cents)

    assert_equal 1, Donations::Payment.count
    assert_equal payment_1, payment_2
  end
end
