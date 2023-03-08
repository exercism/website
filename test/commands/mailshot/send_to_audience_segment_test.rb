require 'test_helper'

class Mailshot::SendToAudienceSegmentTest < ActiveSupport::TestCase
  test "schedules next batch correctly if there are more records" do
    Array.new(4) { create :user, :admin }
    mailshot = create :mailshot

    assert_enqueued_with(
      job: MandateJob, args: [
        "Mailshot::SendToAudienceSegment",
        mailshot,
        :admins,
        :foobar,
        3,
        3
      ]
    ) do
      Mailshot::SendToAudienceSegment.(mailshot, :admins, :foobar, 3, 0)
    end
  end

  test "doesn't schedule if there weren't enough records" do
    Array.new(2) { create :user, :admin }
    mailshot = create :mailshot

    assert_no_enqueued_jobs only: MandateJob do
      Mailshot::SendToAudienceSegment.(mailshot, :admins, :foobar, 3, 0)
    end
  end

  test "schedules if record counts matched" do
    Array.new(3) { create :user, :admin }
    mailshot = create :mailshot

    assert_enqueued_with(job: MandateJob) do
      Mailshot::SendToAudienceSegment.(mailshot, :admins, :foobar, 3, 0)
    end
  end

  test "schedules correct jobs for a track" do
    mailshot = create :mailshot
    track = create :track

    # ###
    # ##
    # Good user with 2 complete solutions in a track
    good_user = create(:user)
    create :user_track, user: good_user, track: track
    2.times do
      exercise = create :practice_exercise, :random_slug, track: track
      create :practice_solution, exercise:, user: good_user, completed_at: Time.current
    end

    # ###
    # ##
    # Only 1 completed
    bad_user_1 = create(:user)
    create :user_track, user: bad_user_1, track: track

    # Completed
    exercise = create :practice_exercise, :random_slug, track: track
    create :practice_solution, exercise:, user: bad_user_1, completed_at: Time.current

    # Not completed
    exercise = create :practice_exercise, :random_slug, track: track
    create :practice_solution, exercise: exercise, user: bad_user_1

    ###
    ##
    # Only 1 for this track, but 1 for one other
    bad_user_2 = create(:user)
    create :user_track, user: bad_user_2, track: track

    # This track
    exercise = create :practice_exercise, :random_slug, track: track
    create :practice_solution, exercise:, user: bad_user_2, completed_at: Time.current

    # Another track
    exercise = create :practice_exercise, :random_slug, track: create(:track, slug: SecureRandom.uuid)
    create :practice_solution, exercise: exercise, user: bad_user_2, completed_at: Time.current

    User::Mailshot::Send.expects(:call).with(good_user, mailshot)
    User::Mailshot::Send.expects(:call).with(bad_user_1, mailshot).never
    User::Mailshot::Send.expects(:call).with(bad_user_2, mailshot).never

    Mailshot::SendToAudienceSegment.(mailshot, :track, track.slug, 10, 0)
  end
end
