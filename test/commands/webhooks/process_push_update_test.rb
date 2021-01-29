require "test_helper"

class Webhooks::ProcessPushUpdateTest < ActiveSupport::TestCase
  test "should enqueue sync push job when pushing to main branch" do
    create :track, slug: 'ruby'

    assert_enqueued_jobs 1, only: ProcessPushUpdateJob do
      Webhooks::ProcessPushUpdate.('refs/heads/main', 'ruby')
    end
  end

  test "should not enqueue sync push job when pushing to non-main branch" do
    create :track, slug: :ruby

    assert_enqueued_jobs 0, only: ProcessPushUpdateJob do
      Webhooks::ProcessPushUpdate.('refs/heads/develop', 'ruby')
    end
  end

  test "should not enqueue sync push job when pushing to non-valid track" do
    create :track, slug: :ruby

    assert_enqueued_jobs 0, only: ProcessPushUpdateJob do
      Webhooks::ProcessPushUpdate.('refs/heads/develop', 'fsharp')
    end
  end
end
