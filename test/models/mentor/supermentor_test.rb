require "test_helper"

class Mentor::SupermentorTest < ActiveSupport::TestCase
  test "eligible?" do
    track = create :track, :random_slug
    user = create :user

    # Sanity check: no mentor
    refute Mentor::Supermentor.eligible?(user)

    # Sanity check: mentor but not mentored anything
    create :user_track_mentorship, user: user, track: track
    user.update(roles: [:mentor])
    refute Mentor::Supermentor.eligible?(user.reload)

    # Sanity check: ignore other user's track mentorships
    other_user = create :user
    create :user_track_mentorship, num_finished_discussions: 150, user: other_user, track: track
    refute Mentor::Supermentor.eligible?(user.reload)

    # Sanity check: mentored too few students
    create_list(:mentor_discussion, 92, :student_finished, rating: :great, track:, mentor: user)
    perform_enqueued_jobs
    refute Mentor::Supermentor.eligible?(user.reload)

    # Sanity check: mentored enough students but too satisfactiong rating too low
    create_list(:mentor_discussion, 10, :student_finished, rating: :problematic, track:, mentor: user)
    perform_enqueued_jobs
    refute Mentor::Supermentor.eligible?(user.reload)

    # Requirements met
    create_list(:mentor_discussion, 80, :student_finished, rating: :great, track:, mentor: user)
    perform_enqueued_jobs
    assert Mentor::Supermentor.eligible?(user.reload)
  end

  test "for_track?" do
    track = create :track, :random_slug
    other_track = create :track, :random_slug
    mentor = create :user
    other_mentor = create :user

    # Sanity check: not mentored anything
    refute Mentor::Supermentor.for_track?(mentor, track)

    # Sanity check: just below threshold
    create_list(:mentor_discussion, 99, :student_finished, track:, mentor:)
    refute Mentor::Supermentor.for_track?(mentor, track)

    # Sanity check: ignore discussion with status: awaiting_student
    create :mentor_discussion, :awaiting_student, track: track, mentor: mentor
    refute Mentor::Supermentor.for_track?(mentor, track)

    # Sanity check: ignore discussion with status: awaiting_mentor
    create :mentor_discussion, :awaiting_mentor, track: track, mentor: mentor
    refute Mentor::Supermentor.for_track?(mentor, track)

    # Sanity check: ignore discussion with status: mentor_finished
    create :mentor_discussion, :mentor_finished, track: track, mentor: mentor
    refute Mentor::Supermentor.for_track?(mentor, track)

    # Sanity check: ignore discussion of other track
    create :mentor_discussion, :student_finished, track: other_track, mentor: mentor
    refute Mentor::Supermentor.for_track?(mentor, track)

    # Sanity check: ignore discussion of other mentor
    create :mentor_discussion, :student_finished, track: track, mentor: other_mentor
    refute Mentor::Supermentor.for_track?(mentor, track)

    create :mentor_discussion, :student_finished, track: track, mentor: mentor
    assert Mentor::Supermentor.for_track?(mentor, track)
  end

  %i[admin staff].each do |role|
    test "for_track? enabled for #{role}" do
      track = create :track
      user = create :user, role

      assert Mentor::Supermentor.for_track?(user, track)
    end
  end
end
