require "test_helper"

class Badge::MentorBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :mentor_badge
    assert_equal "Mentor", badge.name
    assert_equal :rare, badge.rarity
    assert_equal :mentor, badge.icon
    assert_equal "Mentored 10 students", badge.description
    refute badge.send_email_on_acquisition?
  end

  test "award_to?" do
    mentor = create :user
    badge = create :mentor_badge

    # No mentoring being done
    refute badge.award_to?(mentor.reload)

    # 10 finished mentor discussions with the same student is not enough
    student = create :user
    10.times do |_idx|
      solution = create :practice_solution, user: student
      create :mentor_discussion, :student_finished, student:, mentor:, solution:
    end
    refute badge.award_to?(mentor.reload)

    # 9 finished mentor discussions with different students is not enough
    8.times do |_idx|
      solution = create :practice_solution
      create :mentor_discussion, :student_finished, mentor:, solution:
    end
    refute badge.award_to?(mentor.reload)

    # 10th student discussion: don't award if not finished
    solution = create :practice_solution
    discussion = create(:mentor_discussion, mentor:, solution:)
    refute badge.award_to?(mentor.reload)

    # 10th student discussion: don't award if only finished by mentor
    Mentor::Discussion::FinishByMentor.(discussion)
    refute badge.award_to?(mentor.reload)

    # 10th student discussion: award if finished by student
    Mentor::Discussion::FinishByStudent.(discussion, 5)
    assert badge.award_to?(mentor.reload)
  end
end
