require 'test_helper'

class Submission::TestRun::InitTest < ActiveSupport::TestCase
  test "calls to publish_message" do
    solution = create :concept_solution
    submission_uuid = SecureRandom.compact_uuid
    s3_uri = "s3://..."

    ToolingJob::Create.expects(:call).with(
      :test_runner,
      submission_uuid: submission_uuid,
      language: solution.track.slug,
      exercise: solution.exercise.slug,
      s3_uri: s3_uri
    )
    Submission::TestRun::Init.(
      submission_uuid,
      solution.track.slug,
      solution.exercise.slug,
      s3_uri
    )
  end
end
