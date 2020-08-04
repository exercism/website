require 'test_helper'

class Iteration::Representation::InitTest < ActiveSupport::TestCase
  test "calls to publish_message" do
    solution = create :concept_solution
    iteration_uuid = SecureRandom.compact_uuid
    s3_uri = "s3://..."

    ToolingJob::Create.expects(:call).with(
      :representer,
      iteration_uuid: iteration_uuid,
      language: solution.track.slug,
      exercise: solution.exercise.slug,
      s3_uri: s3_uri
    )
    Iteration::Representation::Init.(iteration_uuid, solution.track.slug, solution.exercise.slug, s3_uri)
  end
end
