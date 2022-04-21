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
    solution = create :practice_solution, user: user
    solution.update_column(:last_iterated_at, Time.current - 1.week)
    create :mentor_discussion, solution: solution, created_at: Time.current - 1.day
    solution.update_column(:last_iterated_at, Time.current)

    perform_enqueued_jobs do
      # The default for the growth_mindset badge is to send an email
      User::Notification::CreateEmailOnly.expects(:call).once
      AwardBadgeJob.perform_now(user.reload, :growth_mindset)
    end
  end

  test "override badge email setting" do
    user = create :user
    solution = create :practice_solution, user: user
    solution.update_column(:last_iterated_at, Time.current - 1.week)
    create :mentor_discussion, solution: solution, created_at: Time.current - 1.day
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

    # The whatever badge is only queued when the exercise is bob
    AwardBadgeJob.perform_later(user, 'whatever', exercise: 'leap')
  end
end
