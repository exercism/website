require_relative '../test_base'

class Payments::Payment::CreateTest < Payments::TestBase
  test "creates correctly" do
    freeze_time do
      user = create :user
      id = SecureRandom.uuid
      amount = 1500
      receipt_url = SecureRandom.uuid

      Payments::Payment::Create.(user, :stripe, :donation, id, amount, receipt_url)

      assert_equal 1, Payments::Payment.count

      payment = Payments::Payment.last
      assert_equal id, payment.external_id
      assert_equal amount, payment.amount_in_cents
      assert_equal receipt_url, payment.external_receipt_url
      assert_equal user, payment.user
      assert_equal :stripe, payment.provider
      assert_equal :donation, payment.product
      assert_nil payment.subscription
      assert_equal amount, user.total_donated_in_cents
      assert_equal Time.current, user.first_donated_at
      assert user.donated?
    end
  end

  test "awards supporter badge" do
    user = create :user
    refute user.reload.badges.present?

    assert_enqueued_with(job: AwardBadgeJob) do
      Payments::Payment::Create.(user, :stripe, :donation, 1, 1, "")
    end

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::SupporterBadge
  end

  test "sends email for donation" do
    user = create :user

    perform_enqueued_jobs do
      Payments::Payment::Create.(user, :stripe, :donation, 1, 1, "")
    end

    deliveries = ActionMailer::Base.deliveries.select { |d| d.subject == "Thank you for your donation" && d.to == [user.email] }
    assert_equal 1, deliveries.count
  end

  test "sends email for premium" do
    user = create :user

    perform_enqueued_jobs do
      Payments::Payment::Create.(user, :stripe, :premium, 1, 1, "")
    end

    deliveries = ActionMailer::Base.deliveries.select { |d| d.subject == "Welcome to Exercism Premium!" && d.to == [user.email] }
    assert_equal 1, deliveries.count
  end

  test "works with subscription passed manually" do
    user = create :user
    subscription = create :payments_subscription

    Payments::Payment::Create.(user, :stripe, :donation, 5, 1500, "", subscription:)

    assert_equal 1, Payments::Payment.count

    payment = Payments::Payment.last
    assert_equal subscription, payment.subscription
  end

  test "updates premium_until" do
    freeze_time do
      user = create :user, premium_until: Time.current - 2.days
      id = SecureRandom.uuid
      amount = 1500
      receipt_url = SecureRandom.uuid
      provider = :stripe

      subscription = create(:payments_subscription, :active, user:, provider:)

      payment = Payments::Payment::Create.(user, provider, :premium, id, amount, receipt_url, subscription:)

      assert_equal payment.created_at + 45.days, user.premium_until
    end
  end

  test "idempotent" do
    user = create :user
    id = SecureRandom.uuid
    amount = 1500

    payment_1 = Payments::Payment::Create.(user, :stripe, :donation, id, amount, "")
    payment_2 = Payments::Payment::Create.(user, :stripe, :donation, id, amount, "")

    assert_equal 1, Payments::Payment.count
    assert_equal payment_1, payment_2
  end
end
