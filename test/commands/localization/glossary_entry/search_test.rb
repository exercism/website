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

  test "excludes entries with excluded_ids" do
    user = create :user
    user.stubs(translator_locales: %i[hu nl])

    glossary_entry_1 = create :localization_glossary_entry, locale: "hu", term: "term1", status: :checked
    glossary_entry_2 = create :localization_glossary_entry, locale: "nl", term: "term2", status: :checked
    glossary_entry_3 = create :localization_glossary_entry, locale: "hu", term: "term3", status: :checked

    actual = Localization::GlossaryEntry::Search.(user, excluded_ids: [glossary_entry_1.id, glossary_entry_3.id])

    expected = [glossary_entry_2]
    assert_equal expected, actual.to_a
  end

  test "handles empty excluded_ids array" do
    user = create :user
    user.stubs(translator_locales: %i[hu nl])

    glossary_entry_1 = create :localization_glossary_entry, locale: "hu", term: "term1", status: :checked
    glossary_entry_2 = create :localization_glossary_entry, locale: "nl", term: "term2", status: :checked

    actual = Localization::GlossaryEntry::Search.(user, excluded_ids: [])

    expected = [glossary_entry_1, glossary_entry_2]
    assert_equal expected, actual.to_a
  end

  test "combines excluded_ids with other filters" do
    user = create :user
    user.stubs(translator_locales: %i[hu nl])

    glossary_entry_1 = create :localization_glossary_entry, locale: "hu", term: "foobar", status: :unchecked
    glossary_entry_2 = create :localization_glossary_entry, locale: "hu", term: "foobaz", status: :unchecked
    glossary_entry_3 = create :localization_glossary_entry, locale: "hu", term: "fooqux", status: :unchecked
    create :localization_glossary_entry, locale: "hu", term: "bazqux", status: :unchecked
    create :localization_glossary_entry, locale: "hu", term: "foobar", status: :checked

    actual = Localization::GlossaryEntry::Search.(
      user,
      criteria: "foo",
      status: :unchecked,
      locale: "hu",
      excluded_ids: [glossary_entry_1.id]
    )

    expected = [glossary_entry_2, glossary_entry_3]
    assert_equal expected, actual.to_a
  end

  test "includes pending addition proposals" do
    user = create :user
    user.stubs(translator_locales: %i[hu nl])

    create :localization_glossary_entry, locale: "hu", term: "apple", status: :checked
    create :localization_glossary_entry_proposal, :addition,
      locale: "hu", term: "banana", translation: "banán", status: :pending

    # Rejected proposal should not be included
    create :localization_glossary_entry_proposal, :addition,
      locale: "hu", term: "cherry", translation: "cseresznye", status: :rejected

    # Approved proposal should not be included
    create :localization_glossary_entry_proposal, :addition,
      locale: "hu", term: "date", translation: "datolya", status: :approved

    actual = Localization::GlossaryEntry::Search.(user)

    assert_equal 2, actual.count
    terms = actual.map(&:term).sort
    assert_equal %w[apple banana], terms
  end

  test "proposals do not duplicate existing glossary entries" do
    user = create :user
    user.stubs(translator_locales: %i[hu])

    # Existing entry
    create :localization_glossary_entry, locale: "hu", term: "apple",
      translation: "alma", status: :checked

    # Proposal for the same term+locale (should not appear in results)
    create :localization_glossary_entry_proposal, :addition,
      locale: "hu", term: "apple", translation: "új_alma", status: :pending

    actual = Localization::GlossaryEntry::Search.(user)

    assert_equal 1, actual.count
    assert_equal "apple", actual.first.term
    assert_equal "alma", actual.first.translation # Should be the glossary entry, not proposal
  end

  test "filters proposals by criteria" do
    user = create :user
    user.stubs(translator_locales: %i[hu])

    create :localization_glossary_entry_proposal, :addition,
      locale: "hu", term: "foobar", translation: "translation1", status: :pending
    create :localization_glossary_entry_proposal, :addition,
      locale: "hu", term: "bazqux", translation: "contains foo here", status: :pending
    create :localization_glossary_entry_proposal, :addition,
      locale: "hu", term: "other", translation: "other", status: :pending

    actual = Localization::GlossaryEntry::Search.(user, criteria: "foo")

    assert_equal 2, actual.count
    terms = actual.map(&:term).sort
    assert_equal %w[bazqux foobar], terms
  end

  test "filters proposals by locale" do
    user = create :user
    user.stubs(translator_locales: %i[hu nl])

    create :localization_glossary_entry_proposal, :addition,
      locale: "hu", term: "apple", status: :pending
    create :localization_glossary_entry_proposal, :addition,
      locale: "nl", term: "banana", status: :pending

    actual = Localization::GlossaryEntry::Search.(user, locale: "hu")

    assert_equal 1, actual.count
    assert_equal "apple", actual.first.term
  end

  test "proposals respect user translator locales" do
    user = create :user
    user.stubs(translator_locales: %i[hu])

    create :localization_glossary_entry_proposal, :addition,
      locale: "hu", term: "apple", status: :pending
    create :localization_glossary_entry_proposal, :addition,
      locale: "nl", term: "banana", status: :pending # Should not appear
    create :localization_glossary_entry_proposal, :addition,
      locale: "en", term: "cherry", status: :pending # Should not appear

    actual = Localization::GlossaryEntry::Search.(user)

    assert_equal 1, actual.count
    assert_equal "apple", actual.first.term
  end

  test "only includes addition proposals not modifications or deletions" do
    user = create :user
    user.stubs(translator_locales: %i[hu])

    entry = create :localization_glossary_entry, locale: "hu", term: "existing", status: :checked

    create :localization_glossary_entry_proposal, :addition,
      locale: "hu", term: "new_term", status: :pending
    create :localization_glossary_entry_proposal, :modification,
      glossary_entry: entry, locale: "hu", term: "existing", status: :pending
    create :localization_glossary_entry_proposal, :deletion,
      glossary_entry: entry, locale: "hu", term: "existing", status: :pending

    actual = Localization::GlossaryEntry::Search.(user)

    assert_equal 2, actual.count
    terms = actual.map(&:term).sort
    assert_equal %w[existing new_term], terms
  end

  test "combined entries and proposals maintain sort order" do
    user = create :user
    user.stubs(translator_locales: %i[hu nl])

    create :localization_glossary_entry, locale: "nl", term: "zebra", status: :checked
    create :localization_glossary_entry_proposal, :addition,
      locale: "hu", term: "apple", status: :pending
    create :localization_glossary_entry, locale: "hu", term: "banana", status: :checked
    create :localization_glossary_entry_proposal, :addition,
      locale: "nl", term: "apple", status: :pending

    actual = Localization::GlossaryEntry::Search.(user)

    expected_order = [
      %w[hu apple],
      %w[hu banana],
      %w[nl apple],
      %w[nl zebra]
    ]
    actual_order = actual.map { |e| [e.locale, e.term] }
    assert_equal expected_order, actual_order
  end
end
