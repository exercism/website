require_relative '../test_base'

class Payments::Payment::CreateTest < Payments::TestBase
  test "creates correctly" do
    freeze_time do
      user = create :user
      id = SecureRandom.uuid
      amount = 1500
      receipt_url = SecureRandom.uuid

      Payments::Payment::Create.(user, :stripe, id, amount, receipt_url)

      assert_equal 1, Payments::Payment.count

      payment = Payments::Payment.last
      assert_equal id, payment.external_id
      assert_equal amount, payment.amount_in_cents
      assert_equal receipt_url, payment.external_receipt_url
      assert_equal user, payment.user
      assert_equal :stripe, payment.provider
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
      Payments::Payment::Create.(user, :stripe, 1, 1, "")
    end

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::SupporterBadge
  end

  test "sends email for donation" do
    user = create :user

    perform_enqueued_jobs do
      Payments::Payment::Create.(user, :stripe, 1, 1, "")
    end

    deliveries = ActionMailer::Base.deliveries.select { |d| d.subject == "Thank you for your donation" && d.to == [user.email] }
    assert_equal 1, deliveries.count
  end

  test "works with subscription passed manually" do
    user = create :user
    subscription = create :payments_subscription

    Payments::Payment::Create.(user, :stripe, 5, 1500, "", subscription:)

    assert_equal 1, Payments::Payment.count

    payment = Payments::Payment.last
    assert_equal subscription, payment.subscription
  end

  test "idempotent" do
    user = create :user
    id = SecureRandom.uuid
    amount = 1500

    payment_1 = Payments::Payment::Create.(user, :stripe, id, amount, "")
    payment_2 = Payments::Payment::Create.(user, :stripe, id, amount, "")

    assert_equal 1, Payments::Payment.count
    assert_equal payment_1, payment_2
  end

  test "handles insiders status correctly" do
    # Eligible for 498
    user = create :user
    Payments::Payment::Create.(user, :stripe, SecureRandom.uuid, 498_00, "")
    assert_equal :active, user.reload.insiders_status

    # Eligible lifetime for two payments equaling 499
    user = create :user
    Payments::Payment::Create.(user, :stripe, SecureRandom.uuid, 200_00, "")
    Payments::Payment::Create.(user, :stripe, SecureRandom.uuid, 299_00, "")
    assert_equal :active_lifetime, user.reload.insiders_status

    # Or one payment of 499
    user = create :user
    Payments::Payment::Create.(user, :stripe, SecureRandom.uuid, 499_00, "")
    assert_equal :active_lifetime, user.reload.insiders_status

    # For tiny payment, you don't get insiders
    user = create :user
    Payments::Payment::Create.(user, :stripe, SecureRandom.uuid, 5_00, "")
    assert_equal :unset, user.reload.insiders_status
  end
end
