require_relative '../test_base'

class Donations::Payment::CreateTest < Donations::TestBase
  test "creates correctly" do
    freeze_time do
      user = create :user
      id = SecureRandom.uuid
      amount = 1500
      receipt_url = SecureRandom.uuid

      Donations::Payment::Create.(user, :stripe, id, amount, receipt_url)

      assert_equal 1, Donations::Payment.count

      payment = Donations::Payment.last
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
      Donations::Payment::Create.(user, :stripe, 1, 1, "")
    end

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::SupporterBadge
  end

  test "sends email" do
    user = create :user

    perform_enqueued_jobs do
      Donations::Payment::Create.(user, :stripe, 1, 1, "")
    end

    delivery = ActionMailer::Base.deliveries.find { |d| d.subject == "Thank you for your donation" }
    assert_equal [user.email], delivery.to
  end

  test "works with subscription passed manually" do
    user = create :user
    subscription = create :donations_subscription

    Donations::Payment::Create.(user, :stripe, 5, 1500, "", subscription:)

    assert_equal 1, Donations::Payment.count

    payment = Donations::Payment.last
    assert_equal subscription, payment.subscription
  end

  test "idempotent" do
    user = create :user
    id = SecureRandom.uuid
    amount = 1500

    payment_1 = Donations::Payment::Create.(user, :stripe, id, amount, "")
    payment_2 = Donations::Payment::Create.(user, :stripe, id, amount, "")

    assert_equal 1, Donations::Payment.count
    assert_equal payment_1, payment_2
  end
end
