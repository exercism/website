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

    Mailshot::SendToAudienceSegment.(mailshot, :admins, :foobar, 3, 0)
    perform_enqueued_jobs_until_empty # This shouldn't loop forever!
  end

  test "schedules if there were any jobs returned" do
    create :user, :admin
    mailshot = create :mailshot

    assert_enqueued_with(job: MandateJob) do
      Mailshot::SendToAudienceSegment.(mailshot, :admins, :foobar, 3, 0)
    end
  end

  test "schedules audience_for_donors" do
    mailshot = create :mailshot

    good_user = create :user, :donor
    bad_user = create :user

    User::Mailshot::Send.expects(:call).with(good_user, mailshot)
    User::Mailshot::Send.expects(:call).with(bad_user, mailshot).never

    Mailshot::SendToAudienceSegment.(mailshot, :donors, nil, 10, 0)
  end

  test "schedules audience_for_insiders" do
    mailshot = create :mailshot

    good_user = create :user, :insider
    bad_user = create :user

    User::Mailshot::Send.expects(:call).with(good_user, mailshot)
    User::Mailshot::Send.expects(:call).with(bad_user, mailshot).never

    Mailshot::SendToAudienceSegment.(mailshot, :insiders, nil, 10, 0)
  end

  test "schedules audience_for_challenge" do
    mailshot = create :mailshot

    good_user = create :user, :donor
    create :user_challenge, challenge_id: '12in23', user: good_user

    bad_user = create :user
    create :user_challenge, challenge_id: 'foobar', user: bad_user

    User::Mailshot::Send.expects(:call).with(good_user, mailshot)
    User::Mailshot::Send.expects(:call).with(bad_user, mailshot).never

    Mailshot::SendToAudienceSegment.(mailshot, :challenge, '12in23', 10, 0)
  end

  test "schedules audience_for_reputation" do
    mailshot = create :mailshot

    good_user_1 = create :user, reputation: 50
    good_user_2 = create :user, reputation: 51
    bad_user = create :user, reputation: 49

    User::Mailshot::Send.expects(:call).with(good_user_1, mailshot)
    User::Mailshot::Send.expects(:call).with(good_user_2, mailshot)
    User::Mailshot::Send.expects(:call).with(bad_user, mailshot).never

    Mailshot::SendToAudienceSegment.(mailshot, :reputation, 50, 10, 0)
  end

  test "schedules audience for recently active" do
    mailshot = create :mailshot

    user_20 = create :user, last_visited_on: 20.days.ago
    user_30 = create :user, last_visited_on: 30.days.ago
    user_40 = create :user, last_visited_on: 40.days.ago
    user_new = create :user
    [user_20, user_30, user_40].each do |user|
      2.times { create :iteration, user: }
    end

    User::Mailshot::Send.expects(:call).with(user_20, mailshot)
    User::Mailshot::Send.expects(:call).with(user_30, mailshot)
    User::Mailshot::Send.expects(:call).with(user_40, mailshot).never
    User::Mailshot::Send.expects(:call).with(user_new, mailshot).never

    Mailshot::SendToAudienceSegment.(mailshot, :recent, 35, 10, 0)
  end

  test "schedules audience_for_track" do
    mailshot = create :mailshot
    track = create :track

    # ###
    # ##
    # Good user with 2 complete solutions in a track
    good_user = create(:user)
    create(:user_track, user: good_user, track:)
    2.times do
      exercise = create(:practice_exercise, :random_slug, track:)
      create :practice_solution, exercise:, user: good_user, completed_at: Time.current
    end

    # ###
    # ##
    # Only 1 completed
    bad_user_1 = create(:user)
    create(:user_track, user: bad_user_1, track:)

    # Completed
    exercise = create(:practice_exercise, :random_slug, track:)
    create :practice_solution, exercise:, user: bad_user_1, completed_at: Time.current

    # Not completed
    exercise = create(:practice_exercise, :random_slug, track:)
    create :practice_solution, exercise:, user: bad_user_1

    ###
    ##
    # Only 1 for this track, but 1 for one other
    bad_user_2 = create(:user)
    create(:user_track, user: bad_user_2, track:)

    # This track
    exercise = create(:practice_exercise, :random_slug, track:)
    create :practice_solution, exercise:, user: bad_user_2, completed_at: Time.current

    # Another track
    exercise = create :practice_exercise, :random_slug, track: create(:track, slug: SecureRandom.uuid)
    create :practice_solution, exercise:, user: bad_user_2, completed_at: Time.current

    User::Mailshot::Send.expects(:call).with(good_user, mailshot)
    User::Mailshot::Send.expects(:call).with(bad_user_1, mailshot).never
    User::Mailshot::Send.expects(:call).with(bad_user_2, mailshot).never

    Mailshot::SendToAudienceSegment.(mailshot, :track, track.slug, 10, 0)
  end

  test "schedules bc audiences" do
    # Firstly let's create users at different seniorities
    absolute_beginner = create :user, seniority: :absolute_beginner
    beginner = create :user, seniority: :beginner
    junior = create :user, seniority: :junior
    mid = create :user, seniority: :mid
    senior = create :user, seniority: :senior

    # Now some users that have viewed the page
    absolute_beginner_viewed = create :user, seniority: :absolute_beginner
    beginner_viewed = create :user, seniority: :beginner
    [absolute_beginner_viewed, beginner_viewed].each do |user|
      create :user_bootcamp_data, user:
    end

    # Now some that have paid
    absolute_beginner_paid = create :user, seniority: :absolute_beginner
    beginner_paid = create :user, seniority: :beginner
    unspecified_paid = create :user, seniority: nil
    [absolute_beginner_paid, beginner_paid, unspecified_paid].each do |user|
      create :user_bootcamp_data, user:, paid_at: Time.current
    end

    # Finally some unspecified users with specific ids for batches
    unspecified_id_199_999 = create :user, seniority: nil, id: 199_999
    unspecified_id_200_000 = create :user, seniority: nil, id: 200_000

    # Let's start with a mailshot to interested people
    mailshot = create :mailshot
    User::Mailshot::Send.expects(:call).with(absolute_beginner_viewed, mailshot)
    User::Mailshot::Send.expects(:call).with(beginner_viewed, mailshot)

    Mailshot::SendToAudienceSegment.(mailshot, :bc_interested, nil, 20, 0)

    # And now to beginners
    mailshot = create :mailshot
    User::Mailshot::Send.expects(:call).with(absolute_beginner, mailshot)
    User::Mailshot::Send.expects(:call).with(absolute_beginner_viewed, mailshot)
    User::Mailshot::Send.expects(:call).with(beginner, mailshot)
    User::Mailshot::Send.expects(:call).with(beginner_viewed, mailshot)

    Mailshot::SendToAudienceSegment.(mailshot, :bc_beginners, nil, 20, 0)

    # And now to juniors
    mailshot = create :mailshot
    User::Mailshot::Send.expects(:call).with(junior, mailshot)
    Mailshot::SendToAudienceSegment.(mailshot, :bc_juniors, nil, 20, 0)

    # And now to mids and seniors
    mailshot = create :mailshot
    User::Mailshot::Send.expects(:call).with(mid, mailshot)
    User::Mailshot::Send.expects(:call).with(senior, mailshot)
    Mailshot::SendToAudienceSegment.(mailshot, :bc_mid_seniors, nil, 20, 0)

    # And now to unspecifieds
    mailshot = create :mailshot
    User::Mailshot::Send.expects(:call).with(unspecified_id_199_999, mailshot)
    Mailshot::SendToAudienceSegment.(mailshot, :bc_unspecified, 1, 20, 0)

    User::Mailshot::Send.expects(:call).with(unspecified_id_200_000, mailshot)
    Mailshot::SendToAudienceSegment.(mailshot, :bc_unspecified, 2, 20, 0)
  end

  test "schedules bc unspecified audience for recently active" do
    mailshot = create :mailshot

    user = create :user, last_visited_on: 89.days.ago, seniority: nil
    create :user, last_visited_on: 91.days.ago, seniority: nil
    create :user, last_visited_on: 89.days.ago, seniority: :mid

    User::Mailshot::Send.expects(:call).with(user, mailshot)

    Mailshot::SendToAudienceSegment.(mailshot, :bc_unspecified_recent_90, nil, 10, 0)
  end

  test "requeues with deserialization error" do
    class TestSender < Mailshot::SendToAudienceSegment # rubocop:disable Lint/ConstantDefinitionInBlock
      # ActiveJob::DeserializationError uses $! so this needs wrapping like this.
      def call
        raise ActiveRecord::RecordNotFound
      rescue StandardError
        raise ActiveJob::DeserializationError
      end
    end

    mailshot = create :mailshot

    TestSender.defer(mailshot, :admins, :foobar, 3, 0)
    assert_raise ActiveJob::DeserializationError do
      perform_enqueued_jobs
    end
  end
end
