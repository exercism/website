require "test_helper"

class Github::IssueLabelTest < ActiveSupport::TestCase
  %i[create fix improve proofread sync].each do |action|
    test "for_action #{action}" do
      assert_equal "x:action/#{action}", Github::IssueLabel.for_action(action)
    end
  end

  test "for_action unknown" do
    assert_nil Github::IssueLabel.for_action(:unknown)
  end

  %i[none elementary intermediate advanced].each do |knowledge|
    test "for_knowledge #{knowledge}" do
      assert_equal "x:knowledge/#{knowledge}", Github::IssueLabel.for_knowledge(knowledge)
    end
  end

  test "for_knowledge unknown" do
    assert_nil Github::IssueLabel.for_knowledge(:unknown)
  end

  %i[analyzer concept_exercise concept generator practice_exercise representer test_runner].each do |mod|
    test "for_module #{mod}" do
      assert_equal "x:module/#{mod}", Github::IssueLabel.for_module(mod)
    end
  end

  test "for_module unknown" do
    assert_nil Github::IssueLabel.for_module(:unknown)
  end

  %i[xs s m l xl].each do |size|
    test "for_size #{size}" do
      assert_equal "x:size/#{size}", Github::IssueLabel.for_size(size)
    end
  end

  test "for_size unknown" do
    assert_nil Github::IssueLabel.for_size(:unknown)
  end

  %i[ci coding content docker docs].each do |size|
    test "for_type #{size}" do
      assert_equal "x:type/#{size}", Github::IssueLabel.for_type(size)
    end
  end

  test "for_type unknown" do
    assert_nil Github::IssueLabel.for_type(:unknown)
  end

  test "for_status claimed" do
    assert_equal "x:status/claimed", Github::IssueLabel.for_status(:claimed)
  end

  test "for_status unknown" do
    assert_nil Github::IssueLabel.for_status(:unknown)
  end
end
