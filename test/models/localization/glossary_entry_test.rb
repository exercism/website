require "test_helper"

class Localization::GlossaryEntryTest < ActiveSupport::TestCase
  test "has statuses" do
    assert_equal 4, Localization::GlossaryEntry.statuses.size
    assert_equal %i[generating unchecked proposed checked], Localization::GlossaryEntry.statuses.keys.map(&:to_sym)
  end

  test "status defaults to unchecked on create" do
    glossary_entry = create :localization_glossary_entry
    assert_equal :unchecked, glossary_entry.status
  end

  test "generates uuid on create" do
    glossary_entry = create :localization_glossary_entry
    refute_nil glossary_entry.uuid
    assert_equal 36, glossary_entry.uuid.length
  end

  test "to_param returns uuid" do
    glossary_entry = create :localization_glossary_entry
    assert_equal glossary_entry.uuid, glossary_entry.to_param
  end

  test "status returns symbol" do
    glossary_entry = build :localization_glossary_entry
    glossary_entry.status = :checked
    assert_equal :checked, glossary_entry.status
  end
end
