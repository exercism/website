require_relative '../base_test_case'

class API::Solutions::MentorDiscussionsControllerTest < API::BaseTestCase
  guard_incorrect_token! :finish_api_solution_discussion_path, args: 2, method: :patch

  ###
  # Finish
  ###

  # TODO: Test the 404 and 403

  test "finishes discussion" do
    freeze_time do
      student = create :user, handle: "student"
      setup_user(student)

      solution = create :concept_solution, user: student
      discussion = create(:mentor_discussion, solution:)

      # Assert we don't do things unless we're asked to
      Mentor::Request::Create.expects(:call).never

      patch finish_api_solution_discussion_path(solution.uuid, discussion),
        headers: @headers,
        as: :json,
        params: { rating: 1 }

      assert_response :ok

      discussion.reload
      assert_equal :finished, discussion.status
      assert_equal :student, discussion.finished_by
      assert_equal Time.current, discussion.finished_at
    end
  end

  test "proxies correctly" do
    student = create :user, handle: "student"
    setup_user(student)

    solution = create :concept_solution, user: student
    discussion = create(:mentor_discussion, solution:)

    # Assert we don't do things unless we're asked to
    Mentor::Discussion::FinishByStudent.expects(:call).with(
      discussion,
      4,
      requeue: "requeue_param",
      report: "report_param",
      block: "block_param",
      report_reason: "report_reason_param",
      report_message: "report_message_param",
      testimonial: "testimonial_param"
    )

    patch finish_api_solution_discussion_path(solution.uuid, discussion),
      params: {
        rating: 4,
        requeue: "requeue_param",
        report: "report_param",
        block: "block_param",
        report_reason: "report_reason_param",
        report_message: "report_message_param",
        testimonial: "testimonial_param"
      },
      headers: @headers, as: :json
  end
end
