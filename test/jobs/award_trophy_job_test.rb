require "test_helper"

class AwardTrophyJobTest < ActiveJob::TestCase
  test "trophy is created" do
    user = create :user
    track = create :track
    category = :general
    slug = :mentored

    UserTrack::AcquiredTrophy::Create.expects(:call).with(user, track, category, slug, send_email: true)

    AwardTrophyJob.perform_now(user, track, category, slug)
  end

  test "rescues from TrophyCriteriaNotFulfilledError" do
    user = create :user
    track = create :track
    category = :general
    slug = :mentored

    UserTrack::AcquiredTrophy::Create.expects(:call).with(user, track, category, slug,
      send_email: true).raises(TrophyCriteriaNotFulfilledError)
    AwardTrophyJob.perform_now(user, track, category, slug)
  end

  test "trophy is not created when trophy is not worth queueing" do
    user = create :user
    track = create :track, course: false
    create :track, course: true, slug: 'nim'
    category = :shared
    slug = :completed_learning_mode
    trophy = create :completed_learning_mode_trophy
    trophy.reseed! # Make sure the valid track slugs are up to date

    UserTrack::AcquiredTrophy::Create.expects(:call).never

    # The completed_learning_mode trophy is only queued when the
    # track has learning mode enabled
    perform_enqueued_jobs do
      AwardTrophyJob.perform_later(user, track, category, slug)
    end
  end

  # test "use badge email setting by default" do
  #   user = create :user
  #   solution = create(:practice_solution, user:)
  #   solution.update_column(:last_iterated_at, Time.current - 1.week)
  #   create :mentor_discussion, solution:, created_at: Time.current - 1.day
  #   solution.update_column(:last_iterated_at, Time.current)

  #   perform_enqueued_jobs do
  #     # The default for the growth_mindset badge is to send an email
  #     User::Notification::CreateEmailOnly.expects(:call).once
  #     AwardTrophyJob.perform_now(user.reload, :growth_mindset)
  #   end
  # end

  # test "override badge email setting" do
  #   user = create :user
  #   solution = create(:practice_solution, user:)
  #   solution.update_column(:last_iterated_at, Time.current - 1.week)
  #   create :mentor_discussion, solution:, created_at: Time.current - 1.day
  #   solution.update_column(:last_iterated_at, Time.current)

  #   perform_enqueued_jobs do
  #     # The default for the growth_mindset badge is to send an email, but we override that
  #     User::Notification::CreateEmailOnly.expects(:call).never
  #     AwardTrophyJob.perform_now(user.reload, :growth_mindset, send_email: false)
  #   end
  # end
end
