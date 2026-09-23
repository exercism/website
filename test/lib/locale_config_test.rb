require "test_helper"

class LocaleConfigTest < ActiveSupport::TestCase
  test "rails routing comes from config/i18n.json" do
    config = JSON.parse(File.read(Rails.root.join("config", "i18n.json")))

    assert_equal config["default"], I18n.default_locale.to_s
    assert_equal config["served"], I18n.available_locales.map(&:to_s)
    assert_equal config["public_sections"], LocaleRouting::PUBLIC_SECTIONS
    assert_equal config["public_pages"], LocaleRouting::PUBLIC_PAGES
    assert_equal config["variants"].keys, Locale::Normalize::VARIANTS.keys
  end
end
