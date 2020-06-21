require "test_helper"

class AwardBadgeJobTest < ActiveJob::TestCase
  test "badge create is called" do
    user = mock
    slug = mock

    Badge::Create.expects(:call).with(user, slug)
    AwardBadgeJob.perform_now(user, slug)
  end

  test "rescues from BadgeCriteriaNotFulfilledError" do
    user = mock
    slug = mock

    Badge::Create.expects(:call).with(user, slug).raises(BadgeCriteriaNotFulfilledError)
    AwardBadgeJob.perform_now(user, slug)
  end
end
