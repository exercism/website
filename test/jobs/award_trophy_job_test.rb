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

  test "use trophy email setting by default" do
    user = create :user
    track = create :track

    create(:mentor_discussion, :finished, request: create(:mentor_request, student: user, track:))

    perform_enqueued_jobs do
      # The default for the mentored trophy is to send an email
      User::Notification::CreateEmailOnly.expects(:call).once
      AwardTrophyJob.perform_now(user, track, :general, :mentored)
    end
  end

  test "override trophy email setting" do
    user = create :user
    track = create :track

    create(:mentor_discussion, :finished, request: create(:mentor_request, student: user, track:))

    perform_enqueued_jobs do
      # The default for the mentored trophy is to send an email
      User::Notification::CreateEmailOnly.expects(:call).never
      AwardTrophyJob.perform_now(user, track, :general, :mentored, send_email: false)
    end
  end
end
