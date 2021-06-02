require "test_helper"

class Github::IssueLabelTest < ActiveSupport::TestCase
  %i[create fix improve proofread sync].each do |action|
    test "for_type with action is #{action}" do
      assert_equal "x:action/#{action}", Github::IssueLabel.for_type(:action, action)
    end
  end

  test "for_type with action is unknown" do
    assert_nil Github::IssueLabel.for_type(:action, :unknown)
  end

  %i[none elementary intermediate advanced].each do |knowledge|
    test "for_type with knowledge is #{knowledge}" do
      assert_equal "x:knowledge/#{knowledge}", Github::IssueLabel.for_type(:knowledge, knowledge)
    end
  end

  test "for_type with knowledge is unknown" do
    assert_nil Github::IssueLabel.for_type(:knowledge, :unknown)
  end

  %i[analyzer concept-exercise concept generator practice-exercise representer test-runner].each do |mod|
    test "for_type with module is #{mod}" do
      assert_equal "x:module/#{mod}", Github::IssueLabel.for_type(:module, mod)
    end
  end

  test "for_typr with module is unknown" do
    assert_nil Github::IssueLabel.for_type(:module, :unknown)
  end

  %i[xs s m l xl].each do |size|
    test "for_type with size is #{size}" do
      assert_equal "x:size/#{size}", Github::IssueLabel.for_type(:size, size)
    end
  end

  test "for_type with size is unknown" do
    assert_nil Github::IssueLabel.for_type(:size, :unknown)
  end

  %i[ci coding content docker docs].each do |type|
    test "for_type with type is #{type}" do
      assert_equal "x:type/#{type}", Github::IssueLabel.for_type(:type, type)
    end
  end

  test "for_type with type is unknown" do
    assert_nil Github::IssueLabel.for_type(:type, :unknown)
  end

  test "for_type with status is claimed" do
    assert_equal "x:status/claimed", Github::IssueLabel.for_type(:status, :claimed)
  end

  test "for_type with status is unknown" do
    assert_nil Github::IssueLabel.for_type(:status, :unknown)
  end
end
