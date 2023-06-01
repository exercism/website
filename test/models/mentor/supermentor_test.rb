require "test_helper"

class Mentor::SupermentorTest < ActiveSupport::TestCase
  test "eligible?" do
    track_1 = create :track, :random_slug
    track_2 = create :track, :random_slug
    user = create :user

    # Sanity check: no mentor
    refute Mentor::Supermentor.eligible?(user)

    # Sanity check: mentor role but not mentored anything
    user.update(roles: [:mentor])
    refute Mentor::Supermentor.eligible?(user)

    # Sanity check: ignore other user's mentor discussions
    other_user = create :user
    create_list(:mentor_discussion, 101, :student_finished, solution: create(:practice_solution, track: track_1), mentor: other_user)
    refute Mentor::Supermentor.eligible?(user)

    # Sanity check: mentored too few students
    create_list(:mentor_discussion, 80, :student_finished, solution: create(:practice_solution, track: track_1), mentor: user)
    refute Mentor::Supermentor.eligible?(user)

    # Sanity check: only discussions finished by student count rating too low
    create_list(:mentor_discussion, 20, :awaiting_student, solution: create(:practice_solution, track: track_2), mentor: user)
    create_list(:mentor_discussion, 20, :awaiting_mentor, solution: create(:practice_solution, track: track_2), mentor: user)
    create_list(:mentor_discussion, 20, :mentor_finished, solution: create(:practice_solution, track: track_2), mentor: user)

    # Sanity check: satisfaction rating too low
    create_list(:mentor_discussion, 20, :student_finished, solution: create(:practice_solution, track: track_2), mentor: user)
    user.update(mentor_satisfaction_percentage: 80)
    refute Mentor::Supermentor.eligible?(user.reload)

    # Requirements met
    user.update(mentor_satisfaction_percentage: 96)
    assert Mentor::Supermentor.eligible?(user.reload)
  end

  test "for_track?" do
    track = create :track, :random_slug
    other_track = create :track, :random_slug
    mentor = create :user
    other_mentor = create :user
    mentorship = create(:user_track_mentorship, user: mentor, track:)

    # Sanity check: not mentored anything
    refute Mentor::Supermentor.for_track?(mentor, track)

    # Sanity check: ignore other user's track mentorships
    create(:user_track_mentorship, num_finished_discussions: 150, user: other_mentor, track:)
    refute Mentor::Supermentor.for_track?(mentor, track)

    # Sanity check: ignore other track's mentorships
    create :user_track_mentorship, num_finished_discussions: 177, user: mentor, track: other_track
    refute Mentor::Supermentor.for_track?(mentor, track)

    # Sanity check: mentored too few students
    mentorship.update(num_finished_discussions: 80)
    refute Mentor::Supermentor.for_track?(mentor, track)

    # Sanity check: satisfactiong rating too low
    mentorship.update(num_finished_discussions: 105)
    mentor.update(mentor_satisfaction_percentage: 80)
    refute Mentor::Supermentor.for_track?(mentor, track)

    # Requirements met
    mentor.update(mentor_satisfaction_percentage: 96)
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
