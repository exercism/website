require 'test_helper'

class User::InvalidateCloudflareCachesTest < ActiveSupport::TestCase
  test "defers an invalidation for each published solution" do
    user = create :user
    published = create(:practice_solution, user:, published_at: Time.current, status: :published)
    create(:practice_solution, user:)

    User::InvalidateCloudflareCaches.(user)

    jobs = enqueued_jobs.select do |job|
      job["job_class"] == "MandateJob" &&
        job["arguments"][0] == "Solution::InvalidateCloudflareCache"
    end

    assert_equal 1, jobs.size
    assert_equal published.to_global_id.to_s, jobs.first["arguments"][1]["_aj_globalid"]
  end
end
