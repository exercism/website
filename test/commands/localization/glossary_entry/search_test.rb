require 'test_helper'

class Localization::GlossaryEntry::SearchTest < ActiveSupport::TestCase
  test "searches for user's locales" do
    user = create :user
    user.stubs(translator_locales: %i[hu nl])

    glossary_entry_1 = create :localization_glossary_entry, locale: "hu", term: "term1", status: :checked
    glossary_entry_2 = create :localization_glossary_entry, locale: "nl", term: "term2", status: :checked

    # Different locale (not in user's translator_locales)
    create :localization_glossary_entry, locale: "fr", term: "term3", status: :checked

    # English locale (should be excluded)
    create :localization_glossary_entry, locale: "en", term: "term4", status: :checked

    actual = Localization::GlossaryEntry::Search.(user)

    expected = [glossary_entry_1, glossary_entry_2]
    assert_equal expected, actual.to_a
  end

  test "searches for unchecked glossary entries" do
    user = create :user
    user.stubs(translator_locales: %i[hu nl])

    glossary_entry_1 = create :localization_glossary_entry, locale: "hu", term: "term1", status: :unchecked
    glossary_entry_2 = create :localization_glossary_entry, locale: "nl", term: "term2", status: :unchecked

    # Proposed
    create :localization_glossary_entry, locale: "hu", term: "term3", status: :proposed

    # Checked
    create :localization_glossary_entry, locale: "hu", term: "term4", status: :checked

    actual = Localization::GlossaryEntry::Search.(user, status: :unchecked)

    expected = [glossary_entry_1, glossary_entry_2]
    assert_equal expected, actual.to_a
  end

  test "searches for checked glossary entries" do
    user = create :user
    user.stubs(translator_locales: %i[hu nl])

    glossary_entry_1 = create :localization_glossary_entry, locale: "hu", term: "term1", status: :checked
    glossary_entry_2 = create :localization_glossary_entry, locale: "nl", term: "term2", status: :checked

    # Unchecked
    create :localization_glossary_entry, locale: "hu", term: "term3", status: :unchecked

    # Proposed
    create :localization_glossary_entry, locale: "hu", term: "term4", status: :proposed

    actual = Localization::GlossaryEntry::Search.(user, status: :checked)

    expected = [glossary_entry_1, glossary_entry_2]
    assert_equal expected, actual.to_a
  end

  test "honours criteria for term" do
    user = create :user
    user.stubs(translator_locales: %i[hu nl])

    glossary_entry_1 = create :localization_glossary_entry, locale: "hu", term: "foobar", translation: "something", status: :checked
    create :localization_glossary_entry, locale: "nl", term: "bazqux", translation: "other", status: :checked

    # Different locale (should not be included)
    create :localization_glossary_entry, locale: "fr", term: "foobar", translation: "something", status: :checked

    actual = Localization::GlossaryEntry::Search.(user, criteria: "foo")

    expected = [glossary_entry_1]
    assert_equal expected, actual.to_a
  end

  test "honours criteria for translation" do
    user = create :user
    user.stubs(translator_locales: %i[hu nl])

    glossary_entry_1 = create :localization_glossary_entry, locale: "hu", term: "term1", translation: "contains foo here",
      status: :checked
    create :localization_glossary_entry, locale: "nl", term: "term2", translation: "contains bar here",
      status: :checked

    # Different locale (should not be included)
    create :localization_glossary_entry, locale: "fr", term: "term3", translation: "contains foo here",
      status: :checked

    actual = Localization::GlossaryEntry::Search.(user, criteria: "foo")

    expected = [glossary_entry_1]
    assert_equal expected, actual.to_a
  end

  test "filters by locale" do
    user = create :user
    user.stubs(translator_locales: %i[hu nl fr])

    glossary_entry_1 = create :localization_glossary_entry, locale: "hu", term: "term1", status: :checked
    glossary_entry_2 = create :localization_glossary_entry, locale: "hu", term: "term2", status: :checked
    create :localization_glossary_entry, locale: "nl", term: "term3", status: :checked
    create :localization_glossary_entry, locale: "fr", term: "term4", status: :checked

    actual = Localization::GlossaryEntry::Search.(user, locale: "hu")

    expected = [glossary_entry_1, glossary_entry_2]
    assert_equal expected, actual.to_a
  end

  test "combines filters" do
    user = create :user
    user.stubs(translator_locales: %i[hu nl])

    glossary_entry_1 = create :localization_glossary_entry, locale: "hu", term: "foobar", status: :unchecked
    create :localization_glossary_entry, locale: "hu", term: "bazqux", status: :unchecked
    create :localization_glossary_entry, locale: "hu", term: "foobar", status: :checked
    create :localization_glossary_entry, locale: "nl", term: "foobar", status: :unchecked

    actual = Localization::GlossaryEntry::Search.(user, criteria: "foo", status: :unchecked, locale: "hu")

    expected = [glossary_entry_1]
    assert_equal expected, actual.to_a
  end

  test "orders by locale then term" do
    user = create :user
    user.stubs(translator_locales: %i[hu nl])

    glossary_entry_1 = create :localization_glossary_entry, locale: "nl", term: "zebra", status: :checked
    glossary_entry_2 = create :localization_glossary_entry, locale: "hu", term: "apple", status: :checked
    glossary_entry_3 = create :localization_glossary_entry, locale: "hu", term: "banana", status: :checked
    glossary_entry_4 = create :localization_glossary_entry, locale: "nl", term: "apple", status: :checked

    actual = Localization::GlossaryEntry::Search.(user)

    expected = [glossary_entry_2, glossary_entry_3, glossary_entry_4, glossary_entry_1]
    assert_equal expected, actual.to_a
  end

  test "paginates" do
    Localization::GlossaryEntry::Search.stubs(:default_per).returns(1)

    user = create :user
    user.stubs(translator_locales: %i[hu nl])

    glossary_entry_1 = create :localization_glossary_entry, locale: "hu", term: "term1", status: :checked
    glossary_entry_2 = create :localization_glossary_entry, locale: "nl", term: "term2", status: :checked

    actual = Localization::GlossaryEntry::Search.(user, page: 1)
    assert_equal 2, actual.total_count
    assert_equal 1, actual.size
    assert_includes [glossary_entry_1.id, glossary_entry_2.id], actual.first.id
    assert_equal 1, actual.current_page
    assert_equal 2, actual.total_pages

    actual = Localization::GlossaryEntry::Search.(user, page: 2)
    assert_equal 2, actual.total_count
    assert_equal 1, actual.size
    assert_includes [glossary_entry_1.id, glossary_entry_2.id], actual.first.id
    assert_equal 2, actual.current_page
    assert_equal 2, actual.total_pages

    # Ensure we got different items on each page
    page1_ids = Localization::GlossaryEntry::Search.(user, page: 1).map(&:id)
    page2_ids = Localization::GlossaryEntry::Search.(user, page: 2).map(&:id)
    assert_equal [glossary_entry_1.id, glossary_entry_2.id].sort, (page1_ids + page2_ids).sort
  end

  test "handles custom per page" do
    user = create :user
    user.stubs(translator_locales: [:hu])

    create :localization_glossary_entry, locale: "hu", term: "term1", status: :checked
    create :localization_glossary_entry, locale: "hu", term: "term2", status: :checked
    create :localization_glossary_entry, locale: "hu", term: "term3", status: :checked

    actual = Localization::GlossaryEntry::Search.(user, per: 2, page: 1)
    assert_equal 3, actual.total_count
    assert_equal 2, actual.size
    assert_equal 1, actual.current_page
    assert_equal 2, actual.total_pages

    actual = Localization::GlossaryEntry::Search.(user, per: 2, page: 2)
    assert_equal 3, actual.total_count
    assert_equal 1, actual.size
    assert_equal 2, actual.current_page
    assert_equal 2, actual.total_pages
  end

  test "excludes english locale" do
    user = create :user
    user.stubs(translator_locales: %i[en hu nl])

    glossary_entry_1 = create :localization_glossary_entry, locale: "hu", term: "term1", status: :checked
    glossary_entry_2 = create :localization_glossary_entry, locale: "nl", term: "term2", status: :checked
    create :localization_glossary_entry, locale: "en", term: "term3", status: :checked

    actual = Localization::GlossaryEntry::Search.(user)

    expected = [glossary_entry_1, glossary_entry_2]
    assert_equal expected, actual.to_a
  end

  test "returns empty array when user has no translator locales" do
    user = create :user
    user.stubs(translator_locales: [])

    create :localization_glossary_entry, locale: "hu", term: "term1", status: :checked

    actual = Localization::GlossaryEntry::Search.(user)

    assert_empty actual.to_a
  end

  test "returns empty array when user only has english locale" do
    user = create :user
    user.stubs(translator_locales: [:en])

    create :localization_glossary_entry, locale: "en", term: "term1", status: :checked

    actual = Localization::GlossaryEntry::Search.(user)

    assert_empty actual.to_a
  end
end
