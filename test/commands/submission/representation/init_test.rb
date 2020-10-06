require 'test_helper'

class Submission::Representation::InitTest < ActiveSupport::TestCase
  test "calls to publish_message" do
    solution = create :concept_solution
    submission_uuid = SecureRandom.compact_uuid
    s3_uri = "s3://..."

    ToolingJob::Create.expects(:call).with(
      :representer,
      submission_uuid: submission_uuid,
      language: solution.track.slug,
      exercise: solution.exercise.slug,
      s3_uri: s3_uri
    )
    Submission::Representation::Init.(submission_uuid, solution.track.slug, solution.exercise.slug, s3_uri)
  end
end
