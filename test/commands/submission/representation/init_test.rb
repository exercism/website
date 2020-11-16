require 'test_helper'

class Submission::Representation::InitTest < ActiveSupport::TestCase
  test "calls to publish_message" do
    solution = create :concept_solution
    submission_uuid = SecureRandom.compact_uuid
    job_id = SecureRandom.uuid

    ToolingJob::Create.expects(:call).with(
      job_id,
      :representer,
      submission_uuid: submission_uuid,
      language: solution.track.slug,
      exercise: solution.exercise.slug
    )
    Submission::Representation::Init.(
      job_id,
      submission_uuid,
      solution.track.slug,
      solution.exercise.slug
    )
  end
end
