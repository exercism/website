require 'test_helper'

class Submission::AnalysisTest < ActiveSupport::TestCase
  test "ops_success?" do
    refute create(:submission_analysis, ops_status: 199).ops_success?
    assert create(:submission_analysis, ops_status: 200).ops_success?
    refute create(:submission_analysis, ops_status: 201).ops_success?
  end

  test "ops_errored?" do
    assert create(:submission_analysis, ops_status: 199).ops_errored?
    refute create(:submission_analysis, ops_status: 200).ops_errored?
    assert create(:submission_analysis, ops_status: 201).ops_errored?
  end

  test "comments" do
    comments = [{ 'status' => 'pass' }]
    data = { comments: comments }
    analysis = create :submission_analysis, data: data
    assert_equal comments, analysis.comments
  end

  test "has_feedback?" do
    refute create(:submission_analysis, data: { comments: nil }).has_feedback?
    refute create(:submission_analysis, data: { comments: [] }).has_feedback?
    assert create(:submission_analysis, data: { comments: ['foobar'] }).has_feedback?
  end

  # TODO: - Add a test for if the data is empty
end
