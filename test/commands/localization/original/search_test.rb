require 'test_helper'

class Localization::Original::SearchTest < ActiveSupport::TestCase
  test "searches for user's locales" do
    user = create :user
    user.stubs(translator_locales: %w[hu nl])

    original_1 = create :localization_original
    create :localization_translation, key: original_1.key, locale: "hu", status: :checked
    original_2 = create :localization_original
    create :localization_translation, key: original_2.key, locale: "nl", status: :checked

    # Different locale
    original_3 = create :localization_original
    create :localization_translation, key: original_3.key, locale: "fr", status: :checked

    actual = Localization::Original::Search.(user)

    expected = [original_1, original_2]
    assert_equal expected, actual
  end

  test "searches for unchecked user locales" do
    user = create :user
    user.stubs(translator_locales: %w[hu nl])

    original_1 = create :localization_original
    create :localization_translation, key: original_1.key, locale: "hu", status: :unchecked
    original_2 = create :localization_original
    create :localization_translation, key: original_2.key, locale: "nl", status: :unchecked

    # Proposed
    original_3 = create :localization_original
    create :localization_translation, key: original_3.key, locale: "hu", status: :proposed

    # Checked
    original_4 = create :localization_original
    create :localization_translation, key: original_4.key, locale: "hu", status: :checked

    actual = Localization::Original::Search.(user, status: :unchecked)

    expected = [original_1, original_2]
    assert_equal expected, actual
  end

  test "honours criteria" do
    user = create :user
    user.stubs(translator_locales: %w[hu nl])

    original_1 = create :localization_original
    create :localization_translation, key: original_1.key, locale: "hu", status: :checked, value: "foo"
    original_2 = create :localization_original
    create :localization_translation, key: original_2.key, locale: "nl", status: :checked, value: "bar"

    # Different locale
    original_3 = create :localization_original
    create :localization_translation, key: original_3.key, locale: "fr", status: :checked, value: "foo"

    actual = Localization::Original::Search.(user, criteria: "foo")

    expected = [original_1]
    assert_equal expected, actual
  end

  test "paginates" do
    Localization::Original::Search.stubs(:default_per).returns(1)

    user = create :user
    user.stubs(translator_locales: %w[hu nl])
    original_1 = create :localization_original
    create :localization_translation, key: original_1.key, locale: "hu", status: :checked

    original_2 = create :localization_original
    create :localization_translation, key: original_2.key, locale: "nl", status: :checked

    actual = Localization::Original::Search.(user, page: 1)
    assert_equal 2, actual.total_count
    assert_equal 1, actual.size
    assert_equal original_1.key, actual.first.key
    assert_equal 1, actual.current_page
    assert_equal 2, actual.total_pages

    actual = Localization::Original::Search.(user, page: 2)
    assert_equal 2, actual.total_count
    assert_equal 1, actual.size
    assert_equal original_2.key, actual.first.key
    assert_equal 2, actual.current_page
    assert_equal 2, actual.total_pages
  end
end
