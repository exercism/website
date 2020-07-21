require 'test_helper'

class Iteration::Analysis::InitTest < ActiveSupport::TestCase
  test "calls to publish_message" do
    solution = create :concept_solution
    iteration_uuid = SecureRandom.compact_uuid
    s3_uri = mock
    RestClient.expects(:post).with('http://analyzer.example.com/jobs',
                                   job_type: :analyzer,
                                   iteration_uuid: iteration_uuid,
                                   language: solution.track.slug,
                                   exercise: solution.exercise.slug,
                                   s3_uri: s3_uri,
                                   container_version: nil)
    Iteration::Analysis::Init.(iteration_uuid, solution.track.slug, solution.exercise.slug, s3_uri)
  end

  test "uses version_slug" do
    solution = create :concept_solution
    iteration_uuid = SecureRandom.compact_uuid
    s3_uri = mock
    version_slug = SecureRandom.uuid

    RestClient.expects(:post).with('http://analyzer.example.com/jobs',
                                   job_type: :analyzer,
                                   iteration_uuid: iteration_uuid,
                                   language: solution.track.slug,
                                   exercise: solution.exercise.slug,
                                   s3_uri: s3_uri,
                                   container_version: version_slug)
    Iteration::Analysis::Init.(iteration_uuid, solution.track.slug, solution.exercise.slug, s3_uri, version_slug)
  end
end
