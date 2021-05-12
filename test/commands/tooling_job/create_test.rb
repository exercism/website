require 'test_helper'

class ToolingJob::CreateTest < ActiveSupport::TestCase
  test "stores correctly in redis" do
    freeze_time do
      type = "foobars"
      submission_uuid = SecureRandom.uuid
      language = "ruby"
      exercise = "two-fer"
      attributes = { foo: :bar }

      job = ToolingJob::Create.(type, submission_uuid, language, exercise, attributes)

      redis = Exercism.redis_tooling_client
      expected = {
        foo: :bar,
        id: job.id,
        submission_uuid: submission_uuid,
        type: type,
        language: language,
        exercise: exercise,
        created_at: Time.current.utc.to_i
      }.to_json
      assert_equal expected, redis.get("job:#{job.id}")
      assert_equal job.id, redis.lindex(Exercism::ToolingJob.key_for_queued, 0)
      assert_equal job.id, redis.get("submission:#{submission_uuid}:#{type}")
    end
  end
end
