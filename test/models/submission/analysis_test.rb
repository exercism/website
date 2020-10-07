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

  test "approved?" do
    assert create(:submission_analysis, ops_status: 200, data: { status: :approve }).approved?
    refute create(:submission_analysis, ops_status: 200, data: { status: :disapprove }).approved?
    refute create(:submission_analysis, ops_status: 200, data: { status: :refer_to_mentor }).approved?
    refute create(:submission_analysis, ops_status: 200, data: { status: :misc }).approved?
  end

  test "disapproved?" do
    refute create(:submission_analysis, ops_status: 200, data: { status: :approve }).disapproved?
    assert create(:submission_analysis, ops_status: 200, data: { status: :disapprove }).disapproved?
    refute create(:submission_analysis, ops_status: 200, data: { status: :refer_to_mentor }).disapproved?
    refute create(:submission_analysis, ops_status: 200, data: { status: :misc }).disapproved?
  end

  test "inconclusive?" do
    refute create(:submission_analysis, ops_status: 200, data: { status: :approve }).inconclusive?
    refute create(:submission_analysis, ops_status: 200, data: { status: :disapprove }).inconclusive?
    assert create(:submission_analysis, ops_status: 200, data: { status: :refer_to_mentor }).inconclusive?
    refute create(:submission_analysis, ops_status: 200, data: { status: :misc }).inconclusive?
  end

  test "status" do
    status = "foobar"
    data = { status: status }
    analysis = create :submission_analysis, data: data
    assert_equal status.to_sym, analysis.status
  end

  test "comments" do
    comments = [{ 'status' => 'pass' }]
    data = { comments: comments }
    analysis = create :submission_analysis, data: data
    assert_equal comments, analysis.comments
  end

  # TODO: - Add a test for if the data is empty
end
