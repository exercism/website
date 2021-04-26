require 'test_helper'

class Mentor::Discussion::FinishByStudentTest < ActiveSupport::TestCase
  test "finishes" do
    freeze_time do
      discussion = create :mentor_discussion

      Mentor::Discussion::FinishByStudent.(discussion, 4, requeue: false)

      assert_equal :finished, discussion.status
      assert_equal :student, discussion.finished_by
      assert_equal Time.current, discussion.finished_at
      assert_equal :good, discussion.rating
    end
  end

  test "requeues" do
    comment_markdown = "Pls help me thanks"

    solution = create :concept_solution
    original_request = create :mentor_request, solution: solution, comment_markdown: comment_markdown
    original_request.fulfilled!

    # Check it respects false
    Mentor::Discussion::FinishByStudent.(create(:mentor_discussion), 5)
    assert_equal 1, solution.mentor_requests.size

    # Check it respects true
    discussion = create :mentor_discussion, solution: solution, request: original_request
    Mentor::Discussion::FinishByStudent.(discussion, 5, requeue: true)
    assert_equal :finished, discussion.status
    assert_equal 2, solution.mentor_requests.size

    request = solution.mentor_requests.last
    refute_equal original_request.id, request.id
    assert_equal comment_markdown, request.comment_markdown
  end

  test "reports" do
    # Check it respects false
    Mentor::Discussion::FinishByStudent.(create(:mentor_discussion), 5)
    assert_equal 0, ProblemReport.count

    # Check it respects true
    discussion = create :mentor_discussion
    Mentor::Discussion::FinishByStudent.(
      discussion, 5,
      report: true,
      report_reason: "something",
      report_message: "Oh dear"
    )
    assert_equal :finished, discussion.status
    assert_equal 1, ProblemReport.count

    report = ProblemReport.last
    assert_equal discussion, report.about
    assert_equal discussion.student, report.user
    assert_equal "Oh dear\n\nReason: something", report.content_markdown
    assert_equal :mentoring, report.type

    # Check it respects coc
    Mentor::Discussion::FinishByStudent.(
      create(:mentor_discussion), 5,
      report: true,
      report_reason: "coc",
      report_message: "Oh dear"
    )

    report = ProblemReport.last
    assert_equal :coc, report.type
  end

  test "testimonial" do
    # Check it respects nil
    Mentor::Discussion::FinishByStudent.(create(:mentor_discussion), 5)
    assert_equal 0, Mentor::Testimonial.count

    # Check it respects empty
    Mentor::Discussion::FinishByStudent.(create(:mentor_discussion), 5, testimonial: " \n ")
    assert_equal 0, Mentor::Testimonial.count

    # Check it respects true
    discussion = create :mentor_discussion
    Mentor::Discussion::FinishByStudent.(
      discussion, 5,
      testimonial: "Wow. What a mentor"
    )
    assert_equal :finished, discussion.status
    assert_equal 1, Mentor::Testimonial.count

    testimonial = Mentor::Testimonial.last
    assert_equal discussion.student, testimonial.student
    assert_equal discussion.mentor, testimonial.mentor
    assert_equal discussion, testimonial.discussion
    assert_equal "Wow. What a mentor", testimonial.content
  end

  test "blocking" do
    # Check it respects nil
    Mentor::Discussion::FinishByStudent.(create(:mentor_discussion), 5)
    assert_equal 0, Mentor::StudentRelationship.count

    # Check it respects rating: 1
    discussion = create :mentor_discussion
    Mentor::Discussion::FinishByStudent.(
      discussion, 1
    )
    assert_equal :finished, discussion.status
    assert_equal 1, Mentor::StudentRelationship.count

    relationship = Mentor::StudentRelationship.last
    assert_equal discussion.student, relationship.student
    assert_equal discussion.mentor, relationship.mentor
    assert relationship.blocked_by_student?
    refute relationship.blocked_by_mentor?

    # Check it respects block
    Mentor::Discussion::FinishByStudent.(
      create(:mentor_discussion), 5, block: true
    )
    assert_equal 2, Mentor::StudentRelationship.count
  end
end
