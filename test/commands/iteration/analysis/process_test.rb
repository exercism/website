require 'test_helper'

class Iteration::Analysis::ProcessTest < ActiveSupport::TestCase
  test "creates analysis record" do
    iteration = create :iteration
    ops_status = 200
    ops_message = "some ops message"
    status = "foobar"
    comments = [{ 'foo' => 'bar' }]
    data = { 'status' => status, 'comments' => comments }

    Iteration::Analysis::Process.(iteration.uuid, ops_status, ops_message, data)

    assert_equal 1, iteration.reload.analyses.size
    analysis = iteration.reload.analyses.first

    assert_equal ops_status, analysis.ops_status
    assert_equal ops_message, analysis.ops_message
    assert_equal status.to_sym, analysis.status
    assert_equal comments, analysis.send(:comments)
    assert_equal data, analysis.send(:data)
  end

  test "handle ops error" do
    iteration = create :iteration
    data = { 'status' => :pass, 'comments' => [] }
    Iteration::Analysis::Process.(iteration.uuid, 500, "", data)

    assert iteration.reload.analysis_exceptioned?
  end

  test "handle approval" do
    iteration = create :iteration
    data = { 'status' => :approve, 'comments' => [] }
    Iteration::Analysis::Process.(iteration.uuid, 200, "", data)

    assert iteration.reload.analysis_approved?
  end

  test "handle inconclusive" do
    iteration = create :iteration
    data = { 'status' => :refer_to_mentor, 'comments' => [] }
    Iteration::Analysis::Process.(iteration.uuid, 200, "", data)

    assert iteration.reload.analysis_inconclusive?
  end

  test "handle disapproval" do
    iteration = create :iteration
    data = { 'status' => :disapprove, 'comments' => [] }
    Iteration::Analysis::Process.(iteration.uuid, 200, "", data)

    assert iteration.reload.analysis_disapproved?
  end

  test "handle ambiguous" do
    iteration = create :iteration
    data = { 'status' => :ambiguous, 'comments' => [] }
    Iteration::Analysis::Process.(iteration.uuid, 200, "", data)

    assert iteration.reload.analysis_exceptioned?
  end

  test "broadcast" do
    iteration = create :iteration
    data = { 'status' => :approve, 'comments' => [] }

    IterationChannel.expects(:broadcast!).with(iteration)
    IterationsChannel.expects(:broadcast!).with(iteration.solution)

    Iteration::Analysis::Process.(iteration.uuid, 200, "", data)
  end
end
