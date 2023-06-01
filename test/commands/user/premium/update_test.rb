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

  %i[active overdue].each do |status|
    test "non-insider with #{status} monthly subscription and last payment less than a month ago gets premium with grace period" do
      user = create :user, premium_until: nil

      # Sanity check
      refute user.premium?

      subscription = create(:payments_subscription, :premium, status:, user:, interval: :month)
      create(:payments_payment, :premium, created_at: Time.current - 2.months, user:, subscription:)
      last_payment = create(:payments_payment, :premium, created_at: Time.current - 20.days, user:, subscription:)

      User::Premium::Update.(user)

      assert_equal last_payment.created_at + 1.month + 15.days, user.reload.premium_until
      assert user.premium?
    end
  end

  test "non-insider with canceled monthly subscription and last payment less than a month ago gets premium without grace period" do
    user = create :user, premium_until: nil

    # Sanity check
    refute user.premium?

    subscription = create(:payments_subscription, :premium, status: :canceled, user:, interval: :month)
    create(:payments_payment, :premium, created_at: Time.current - 2.months, user:, subscription:)
    create(:payments_payment, :premium, created_at: Time.current - 20.days, user:, subscription:)

    User::Premium::Update.(user)

    assert_nil user.reload.premium_until
    refute user.premium?
  end

  %i[active overdue canceled].each do |status|
    test "non-insider with #{status} monthly subscription and last payment more than a month ago does not get premium" do
      user = create :user, premium_until: Time.current + 2.days
      subscription = create(:payments_subscription, :premium, status: :canceled, user:, interval: :month)
      create(:payments_payment, :premium, created_at: Time.current - 3.months, user:, subscription:)

      assert user.premium?

      User::Premium::Update.(user)

      assert_nil user.reload.premium_until
      refute user.premium?
    end
  end

  %i[active overdue].each do |status|
    test "non-insider with #{status} yearly subscription and last payment less than a year ago gets premium with grace period" do
      user = create :user, premium_until: nil

      # Sanity check
      refute user.premium?

      subscription = create(:payments_subscription, :premium, status:, user:, interval: :year)
      create(:payments_payment, :premium, created_at: Time.current - 8.months, user:, subscription:)
      last_payment = create(:payments_payment, :premium, created_at: Time.current - 3.months, user:, subscription:)

      User::Premium::Update.(user)

      assert_equal last_payment.created_at + 1.year + 15.days, user.reload.premium_until
      assert user.premium?
    end
  end

  test "non-insider with canceled yearly subscription and last payment less than a year ago gets premium without grace period" do
    user = create :user, premium_until: nil

    # Sanity check
    refute user.premium?

    subscription = create(:payments_subscription, :premium, status: :canceled, user:, interval: :year)
    create(:payments_payment, :premium, created_at: Time.current - 8.months, user:, subscription:)
    create(:payments_payment, :premium, created_at: Time.current - 3.months, user:, subscription:)

    User::Premium::Update.(user)

    assert_nil user.reload.premium_until
    refute user.premium?
  end

  %i[active overdue canceled].each do |status|
    test "non-insider with #{status} yearly subscription and last payment more than a year ago does not get premium" do
      user = create :user, premium_until: Time.current + 2.days
      subscription = create(:payments_subscription, :premium, status: :canceled, user:, interval: :year)
      create(:payments_payment, :premium, created_at: Time.current - 15.months, user:, subscription:)

      assert user.premium?

      User::Premium::Update.(user)

      assert_nil user.reload.premium_until
      refute user.premium?
    end
  end

  test "non-insider is not premium if there are no payments" do
    user = create :user, premium_until: Time.current + 2.days

    assert user.premium?

    User::Premium::Update.(user)

    assert_nil user.reload.premium_until
    refute user.premium?
  end

  test "create notification when user was already lifetime premium" do
    user = create :user, :insider, premium_until: Time.utc(9999, 12, 31)

    User::Notification::CreateEmailOnly.expects(:defer).never

    User::Premium::Update.(user)
  end

  test "don't create notification when user is not lifetime premium" do
    user = create :user

    User::Notification::CreateEmailOnly.expects(:defer).never

    User::Premium::Update.(user)
  end

  test "update flair when user joins premium" do
    user = create :user, premium_until: nil

    subscription = create(:payments_subscription, :premium, :active, user:, interval: :month)
    create(:payments_payment, :premium, created_at: Time.current - 2.months, user:, subscription:)
    create(:payments_payment, :premium, created_at: Time.current - 20.days, user:, subscription:)

    User::UpdateFlair.expects(:call).with(user)

    User::Premium::Update.(user)
  end

  test "update flair when user premium expired" do
    user = create :user, premium_until: Time.current - 1.day

    User::UpdateFlair.expects(:call).with(user)

    User::Premium::Update.(user)
  end

  test "don't update flair when user premium expired" do
    user = create :user, premium_until: Time.current - 1.day

    User::UpdateFlair.expects(:call).with(user)

    User::Premium::Update.(user)
  end

  test "don't update flair when just updating premium_until" do
    user = create :user, premium_until: Time.current - 1.day

    subscription = create(:payments_subscription, :premium, :active, user:, interval: :month)
    create(:payments_payment, :premium, created_at: Time.current - 2.months, user:, subscription:)
    create(:payments_payment, :premium, created_at: Time.current - 20.days, user:, subscription:)

    User::UpdateFlair.expects(:call).never

    User::Premium::Update.(user)
  end
end
