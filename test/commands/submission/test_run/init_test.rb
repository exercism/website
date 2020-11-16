require 'test_helper'

class Submission::TestRun::InitTest < ActiveSupport::TestCase
  test "calls to publish_message" do
    solution = create :concept_solution
    job_id = SecureRandom.uuid
    submission_uuid = SecureRandom.compact_uuid

    ToolingJob::Create.expects(:call).with(
      job_id,
      :test_runner,
      submission_uuid: submission_uuid,
      language: solution.track.slug,
      exercise: solution.exercise.slug
    )
    Submission::TestRun::Init.(
      job_id,
      submission_uuid,
      solution.track.slug,
      solution.exercise.slug
    )
  end
end
