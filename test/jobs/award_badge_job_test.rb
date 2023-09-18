require "test_helper"

class AwardBadgeJobTest < ActiveJob::TestCase
  test "badge create is called" do
    user = mock
    slug = mock

    User::AcquiredBadge::Create.expects(:call).with(user, slug, send_email: true)
    AwardBadgeJob.perform_now(user, slug)
  end

  test "rescues from BadgeCriteriaNotFulfilledError" do
    user = mock
    slug = mock

    User::AcquiredBadge::Create.expects(:call).with(user, slug, send_email: true).raises(BadgeCriteriaNotFulfilledError)
    AwardBadgeJob.perform_now(user, slug)
  end

  test "use badge email setting by default" do
    user = create :user
    solution = create(:practice_solution, user:)
    solution.update_column(:last_iterated_at, Time.current - 1.week)
    create :mentor_discussion, solution:, created_at: Time.current - 1.day
    solution.update_column(:last_iterated_at, Time.current)

    perform_enqueued_jobs do
      # The default for the growth_mindset badge is to send an email
      User::Notification::CreateEmailOnly.expects(:call).once
      AwardBadgeJob.perform_now(user.reload, :growth_mindset)
    end
  end

  test "override badge email setting" do
    user = create :user
    solution = create(:practice_solution, user:)
    solution.update_column(:last_iterated_at, Time.current - 1.week)
    create :mentor_discussion, solution:, created_at: Time.current - 1.day
    solution.update_column(:last_iterated_at, Time.current)

    perform_enqueued_jobs do
      # The default for the growth_mindset badge is to send an email, but we override that
      User::Notification::CreateEmailOnly.expects(:call).never
      AwardBadgeJob.perform_now(user.reload, :growth_mindset, send_email: false)
    end
  end

  test "badge create is not called when badge is not worth queueing" do
    user = mock

    User::AcquiredBadge::Create.expects(:call).never

    # The new_years_resolution badge is only queued on the first day of the year
    iteration = create :iteration, created_at: Date.ordinal(2021, 13)

    perform_enqueued_jobs do
      AwardBadgeJob.perform_later(user, :new_years_resolution, context: iteration)
    end
  end
end
