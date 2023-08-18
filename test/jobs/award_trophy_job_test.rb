require "test_helper"

class AwardTrophyJobTest < ActiveJob::TestCase
  test "trophy is created" do
    user = create :user
    track = create :track
    slug = :mentored

    UserTrack::AcquiredTrophy::Create.expects(:call).with(user, track, slug)

    AwardTrophyJob.perform_now(user, track, slug)
  end

  test "rescues from TrophyCriteriaNotFulfilledError" do
    user = create :user
    track = create :track
    slug = :mentored

    UserTrack::AcquiredTrophy::Create.expects(:call).with(user, track, slug).raises(TrophyCriteriaNotFulfilledError)
    AwardTrophyJob.perform_now(user, track, slug)
  end

  test "trophy is not created when trophy is not worth queueing" do
    user = create :user
    track = create :track, course: false
    create :track, course: true, slug: 'nim'
    slug = :completed_learning_mode
    trophy = create :completed_learning_mode_trophy
    trophy.reseed! # Make sure the valid track slugs are up to date

    UserTrack::AcquiredTrophy::Create.expects(:call).never

    # The completed_learning_mode trophy is only queued when the
    # track has learning mode enabled
    perform_enqueued_jobs do
      AwardTrophyJob.perform_later(user, track, slug)
    end
  end

  test "create notification" do
    user = create :user
    track = create :track

    create(:mentor_discussion, :finished, request: create(:mentor_request, student: user, track:))

    perform_enqueued_jobs do
      User::Notification::Create.expects(:call).once
      AwardTrophyJob.perform_now(user, track, :mentored)
    end
  end
end
