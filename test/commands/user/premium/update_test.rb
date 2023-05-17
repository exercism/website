require "test_helper"

class User::Premium::UpdateTest < ActiveSupport::TestCase
  test "insider gets lifetime premium" do
    user = create :user, :insider, premium_until: nil

    # Sanity check
    refute user.premium?

    User::Premium::Update.(user)

    assert user.reload.premium?

    travel_to Time.current + 50.years
    assert user.premium?
  end

  test "non-insider is premium if last payment date + grace period is in the future" do
    user = create :user, premium_until: nil

    # Sanity check
    refute user.premium?

    create(:payments_payment, product: :premium, created_at: Time.current - 2.months, user:)
    last_payment = create(:payments_payment, product: :premium, created_at: Time.current - 20.days, user:)

    User::Premium::Update.(user)

    assert_equal last_payment.created_at + 45.days, user.reload.premium_until
    assert user.premium?
  end

  test "non-insider is not premium if last payment date + grace period is in the past" do
    user = create :user, premium_until: Time.current + 2.days
    create(:payments_payment, product: :premium, created_at: Time.current - 3.months, user:)

    assert user.premium?

    User::Premium::Update.(user)

    assert_nil user.reload.premium_until
    refute user.premium?
  end

  test "non-insider is not premium if there are no payments" do
    user = create :user, premium_until: Time.current + 2.days

    assert user.premium?

    User::Premium::Update.(user)

    assert_nil user.reload.premium_until
    refute user.premium?
  end

  test "create notification when user is lifetime premium" do
    user = create :user, :insider

    User::Notification::CreateEmailOnly.expects(:defer).with(user, :joined_lifetime_premium).once

    User::Premium::Update.(user)
  end

  test "create notification when user was already lifetime premium" do
    user = create :user, :insider, premium_until: Time.utc(2099, 12, 31)

    User::Notification::CreateEmailOnly.expects(:defer).never

    User::Premium::Update.(user)
  end

  test "don't create notification when user is not lifetime premium" do
    user = create :user

    User::Notification::CreateEmailOnly.expects(:defer).never

    User::Premium::Update.(user)
  end
end
