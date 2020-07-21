require 'test_helper'

class Iteration::TestRun::InitTest < ActiveSupport::TestCase
  test "calls to publish_message" do
    solution = create :concept_solution
    iteration_uuid = SecureRandom.compact_uuid
    s3_uri = mock

    RestClient.expects(:post).with('http://test-runner.example.com/jobs',
                                   job_type: :test_runner,
                                   iteration_uuid: iteration_uuid,
                                   language: solution.track.slug,
                                   exercise: solution.exercise.slug,
                                   s3_uri: s3_uri,
                                   container_version: nil)
    Iteration::TestRun::Init.(iteration_uuid, solution.track.slug, solution.exercise.slug, s3_uri)
  end

  test "uses version_slug" do
    solution = create :concept_solution
    iteration_uuid = SecureRandom.compact_uuid
    version_slug = SecureRandom.uuid
    s3_uri = mock

    RestClient.expects(:post).with('http://test-runner.example.com/jobs',
                                   job_type: :test_runner,
                                   iteration_uuid: iteration_uuid,
                                   language: solution.track.slug,
                                   exercise: solution.exercise.slug,
                                   s3_uri: s3_uri,
                                   container_version: version_slug)
    Iteration::TestRun::Init.(iteration_uuid, solution.track.slug, solution.exercise.slug, s3_uri, version_slug)
  end
end
