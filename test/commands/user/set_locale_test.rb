require "test_helper"

class User::SetLocaleTest < ActiveSupport::TestCase
  test "saves a served locale on the account" do
    user = create :user

    assert User::SetLocale.(user, "hu")
    assert_equal "hu", user.reload.locale
  end

  test "accepts a symbol as readily as a string" do
    user = create :user

    assert User::SetLocale.(user, :hu)
    assert_equal "hu", user.reload.locale
  end

  test "leaves the account alone for a locale we do not serve" do
    user = create :user, locale: "hu"

    refute User::SetLocale.(user, "fr")
    assert_equal "hu", user.reload.locale
  end

  test "leaves the account alone for a blank locale" do
    user = create :user, locale: "hu"

    refute User::SetLocale.(user, "")
    assert_equal "hu", user.reload.locale
  end

  test "leaves the account alone for a nil locale" do
    user = create :user, locale: "hu"

    refute User::SetLocale.(user, nil)
    assert_equal "hu", user.reload.locale
  end
end
