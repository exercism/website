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
    assert create(:iteration_analysis, ops_status: 200, status: :approved).approved?
    refute create(:iteration_analysis, ops_status: 200, status: :disapproved).approved?
    refute create(:iteration_analysis, ops_status: 200, status: :misc).approved?
  end

  test "disapproved?" do
    refute create(:iteration_analysis, ops_status: 200, status: :approved).disapproved?
    assert create(:iteration_analysis, ops_status: 200, status: :disapproved).disapproved?
    refute create(:iteration_analysis, ops_status: 200, status: :misc).disapproved?
  end

  test "explodes raw_analysis" do
    status = "foobar"
    comments = [{'status' => 'pass'}]

    raw_analysis = {
      status: status,
      comments: comments
    }
    analysis = create :iteration_analysis, raw_analysis: raw_analysis
    assert_equal status.to_sym, analysis.status
  end

  # TODO - Add a test for if the raw_analysis is empty
end
