require 'test_helper'

class Submission::Analysis::ProcessTest < ActiveSupport::TestCase
  test "creates analysis record" do
    submission = create :submission
    ops_status = 200
    comments = [{ 'foo' => 'bar' }]
    data = { 'comments' => comments }
    tags = ["construct:while-loop", "paradigm:logic"]
    tags_data = { 'tags' => tags }

    job = create_analyzer_job!(submission, execution_status: ops_status, data:, tags_data:)
    Submission::Analysis::Process.(job)

    analysis = submission.reload.analysis

    assert_equal job.id, analysis.tooling_job_id
    assert_equal ops_status, analysis.ops_status
    assert_equal data, analysis.send(:data)
    assert_equal tags_data, analysis.send(:tags_data)
  end

  test "handle ops error" do
    submission = create :submission
    job = create_analyzer_job!(submission, execution_status: 500, data: nil)

    Bugsnag.expects(:notify).never

    Submission::Analysis::Process.(job)

    assert submission.reload.analysis_exceptioned?
  end

  test "handle completed" do
    submission = create :submission
    data = { 'comments' => [] }
    job = create_analyzer_job!(submission, execution_status: 200, data:)
    Submission::Analysis::Process.(job)

    assert submission.reload.analysis_completed?
  end

  test "broadcast without iteration" do
    submission = create :submission
    data = { 'comments' => [] }

    SubmissionChannel.expects(:broadcast!).with(submission)

    job = create_analyzer_job!(submission, execution_status: 200, data:)
    Submission::Analysis::Process.(job)
  end

  test "broadcast with iteration" do
    submission = create :submission
    iteration = create(:iteration, submission:)
    data = { 'comments' => [] }

    IterationChannel.expects(:broadcast!).with(iteration)
    SubmissionChannel.expects(:broadcast!).with(submission)

    job = create_analyzer_job!(submission, execution_status: 200, data:)
    Submission::Analysis::Process.(job)
  end

  test "updates tags of solution" do
    solution = create :practice_solution
    submission = create(:submission, solution:)
    create(:iteration, submission:)
    data = { 'comments' => [] }

    Solution::UpdateTags.expects(:call).with(submission.solution)

    job = create_analyzer_job!(submission, execution_status: 200, data:)
    Submission::Analysis::Process.(job)
  end

  test "updates tags of submission" do
    solution = create :practice_solution
    submission = create(:submission, solution:)
    create(:iteration, submission:)
    data = { 'comments' => [] }
    tags = ["construct:while-loop", "paradigm:logic"]
    tags_data = { 'tags' => tags }

    job = create_analyzer_job!(submission, execution_status: 200, data:, tags_data:)
    Submission::Analysis::Process.(job)

    assert_equal tags, submission.reload.tags
  end

  test "links to approach" do
    solution = create :practice_solution
    submission = create(:submission, solution:)
    create(:iteration, submission:)
    data = { 'comments' => [] }

    Submission::LinkToMatchingApproach.expects(:call).with(submission)

    job = create_analyzer_job!(submission, execution_status: 200, data:)
    Submission::Analysis::Process.(job)
  end

  test "gracefully handle tags.json not being there" do
    submission = create :submission
    ops_status = 200
    comments = [{ 'foo' => 'bar' }]
    data = { 'comments' => comments }
    execution_output = {
      "analysis.json" => data&.to_json
    }
    job = create_tooling_job!(
      submission,
      :analyzer,
      execution_status: ops_status,
      execution_output:
    )

    Bugsnag.expects(:notify).never

    Submission::Analysis::Process.(job)

    analysis = submission.reload.analysis
    assert_equal job.id, analysis.tooling_job_id
    assert_equal ops_status, analysis.ops_status
    assert_equal data, analysis.send(:data)
    assert_equal ({}), analysis.send(:tags_data)
  end
end
