require "test_helper"

class LocaleInitializerTest < ActiveSupport::TestCase
  test "rails-i18n is loaded for the available locales, and only those" do
    rails_i18n = I18n.load_path.map(&:to_s).select { |path| path.include?("rails-i18n") && path.include?("/rails/locale/") }

    assert_equal I18n.available_locales.map(&:to_s).sort, rails_i18n.map { |path| File.basename(path, ".yml") }.sort
  end

  test "dates and numbers are localised" do
    date = Date.new(2026, 3, 5)

    assert_equal "March 05, 2026", I18n.l(date, format: :long)
    I18n.with_locale(:hu) do
      assert_includes I18n.l(date, format: :long), "március"
      assert_equal "1 234,5", ActiveSupport::NumberHelper.number_to_delimited(1234.5)
    end
  end

  test "activerecord errors are localised" do
    I18n.with_locale(:hu) do
      user = User.new
      user.errors.add(:handle, :blank)
      refute_includes user.errors.full_messages.first, "can't be blank"
    end
  end

  test "plural rules come from the locale" do
    I18n.backend.store_translations(:hu, locale_test: { things: { one: "egy", other: "sok" } })

    I18n.with_locale(:hu) do
      assert_equal "egy", I18n.t("locale_test.things", count: 1)
      assert_equal "sok", I18n.t("locale_test.things", count: 2)
    end
    assert_includes I18n.backend.class.ancestors, I18n::Backend::Pluralization
  end
end
