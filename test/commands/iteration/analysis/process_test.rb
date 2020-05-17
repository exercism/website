require 'test_helper'

class Iteration::Analysis::ProcessTest < ActiveSupport::TestCase

  test "creates analysis record" do
    iteration = create :iteration
    ops_status = 201
    ops_message = "some ops message"
    status = "foobar"
    comments = [{'foo' => 'bar'}]
    analysis = {'status' => status, 'comments' => comments}

    Iteration::Analysis::Process.(iteration.uuid, ops_status, ops_message, analysis)

    assert_equal 1, iteration.reload.analyses.size
    tr = iteration.reload.analyses.first

    assert_equal ops_status, tr.ops_status
    assert_equal ops_message, tr.ops_message
    assert_equal status.to_sym, tr.status
    assert_equal comments, tr.send(:comments_data)
    assert_equal analysis, tr.send(:raw_analysis)
  end

  test "handle ops error" do
    iteration = create :iteration
    analysis = {'status' => :pass, 'comments' => []}
    Iteration::Analysis::Process.(iteration.uuid, 500, "", analysis)

    assert iteration.reload.analysis_exceptioned?
  end

  test "handle approval" do
    iteration = create :iteration
    analysis = {'status' => :approved, 'comments' => []}
    Iteration::Analysis::Process.(iteration.uuid, 200, "", analysis)

    assert iteration.reload.analysis_approved?
  end

  test "handle disapproval" do
    iteration = create :iteration
    analysis = {'status' => :disapproved, 'comments' => []}
    Iteration::Analysis::Process.(iteration.uuid, 200, "", analysis)

    assert iteration.reload.analysis_disapproved?
  end

  test "handle ambiguous" do
    iteration = create :iteration
    analysis = {'status' => :ambiguous, 'comments' => []}
    Iteration::Analysis::Process.(iteration.uuid, 200, "", analysis)

    assert iteration.reload.analysis_exceptioned?
  end
end

