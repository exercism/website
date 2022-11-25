require "test_helper"

class Mentor::SupermentorTest < ActiveSupport::TestCase
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
