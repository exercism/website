require 'test_helper'

class Iteration::AnalysisTest < ActiveSupport::TestCase
  test "ops_success?" do
    refute create(:iteration_analysis, ops_status: 199).ops_success?
    assert create(:iteration_analysis, ops_status: 200).ops_success?
    refute create(:iteration_analysis, ops_status: 201).ops_success?
  end

  test "ops_errored?" do
    assert create(:iteration_analysis, ops_status: 199).ops_errored?
    refute create(:iteration_analysis, ops_status: 200).ops_errored?
    assert create(:iteration_analysis, ops_status: 201).ops_errored?
  end

  test "approved?" do
    assert create(:iteration_analysis, ops_status: 200, data: {status: :approved}).approved?
    refute create(:iteration_analysis, ops_status: 200, data: {status: :disapproved}).approved?
    refute create(:iteration_analysis, ops_status: 200, data: {status: :misc}).approved?
  end

  test "disapproved?" do
    refute create(:iteration_analysis, ops_status: 200, data: {status: :approved}).disapproved?
    assert create(:iteration_analysis, ops_status: 200, data: {status: :disapproved}).disapproved?
    refute create(:iteration_analysis, ops_status: 200, data: {status: :misc}).disapproved?
  end

  test "status" do
    status = "foobar"
    data = { status: status }
    analysis = create :iteration_analysis, data: data
    assert_equal status.to_sym, analysis.status
  end

  test "comments" do
    comments = [{'status' => 'pass'}]
    data = { comments: comments }
    analysis = create :iteration_analysis, data: data
    assert_equal comments, analysis.comments
  end

  # TODO - Add a test for if the data is empty
end
