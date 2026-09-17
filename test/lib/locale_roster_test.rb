require "test_helper"

class LocaleRosterTest < ActiveSupport::TestCase
  test "english is the default and in production" do
    assert_equal :en, LocaleRoster.default
    assert LocaleRoster.production?(:en)
    assert LocaleRoster.default?("en")
  end

  test "hungarian is known but work in progress" do
    assert LocaleRoster.known?(:hu)
    refute LocaleRoster.production?(:hu)
    assert_includes LocaleRoster.wip, :hu
  end

  test "production and wip never overlap and are all known" do
    assert_empty LocaleRoster.production & LocaleRoster.wip
    assert_empty (LocaleRoster.production | LocaleRoster.wip) - LocaleRoster.known
  end

  test "test environment serves english only" do
    assert_equal [:en], LocaleRoster.served
    refute LocaleRoster.served?(:hu)
    refute LocaleRoster.wip?(:hu)
  end

  test "with_served_locales opts a test in" do
    with_served_locales(:hu) do
      assert_equal %i[en hu], LocaleRoster.served
      assert LocaleRoster.wip?(:hu)
      refute LocaleRoster.wip?(:en)
    end
    refute LocaleRoster.served?(:hu)
  end

  test "handles strings, nil and unknown locales" do
    assert LocaleRoster.known?("hu")
    refute LocaleRoster.known?(nil)
    refute LocaleRoster.known?("tracks")
  end

  test "I18n is wired to the roster" do
    assert_equal LocaleRoster.default, I18n.default_locale
    assert_equal LocaleRoster.known.sort, I18n.available_locales.sort
  end
end
