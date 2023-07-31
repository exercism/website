require "test_helper"

class Github::IssueLabelTest < ActiveSupport::TestCase
  test "namespace" do
    label = create :github_issue_label, name: 'x:action/fix'
    assert_equal :exercism, label.namespace
  end

  test "type" do
    label = create :github_issue_label, name: 'x:action/fix'
    assert_equal :action, label.type
  end

  test "value" do
    label = create :github_issue_label, name: 'x:action/fix'
    assert_equal :fix, label.value
  end

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

  test "for_type with module is unknown" do
    assert_nil Github::IssueLabel.for_type(:module, :unknown)
  end

  %i[tiny small medium large massive].each do |rep|
    test "for_type with rep is #{rep}" do
      assert_equal "x:rep/#{rep}", Github::IssueLabel.for_type(:rep, rep)
    end
  end

  test "for_type with rep is unknown" do
    assert_nil Github::IssueLabel.for_type(:rep, :unknown)
  end

  %i[tiny small medium large massive].each do |size|
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

  test "of_type?" do
    label = create :github_issue_label, name: 'x:size/large'
    assert label.of_type?(:size)
    refute label.of_type?(:knowledge)
    refute label.of_type?(:module)
    refute label.of_type?(:status)
    refute label.of_type?(:type)
  end

  test "of_type? with invalid value" do
    label = create :github_issue_label, name: 'x:size/invalid'
    %i[size knowledge module status type].each do |type|
      refute label.of_type?(type)
    end
  end

  test "of_type? with invalid type" do
    label = create :github_issue_label, name: 'x:invalid/small'
    %i[size knowledge module status type].each do |type|
      refute label.of_type?(type)
    end
  end

  test "of_type? with invalid namespace" do
    label = create :github_issue_label, name: 'a:size/small'
    %i[size knowledge module status type].each do |type|
      refute label.of_type?(type)
    end
  end

  test "of_type? with invalid namespace, type and value" do
    label = create :github_issue_label, name: 'a:invalid/weird'
    %i[size knowledge module status type].each do |type|
      refute label.of_type?(type)
    end
  end

  test "of_type? with non-namespaced label" do
    label = create :github_issue_label, name: 'good-first-issue'
    %i[size knowledge module status type].each do |type|
      refute label.of_type?(type)
    end
  end
end
