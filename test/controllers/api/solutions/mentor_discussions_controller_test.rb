require_relative '../base_test_case'

class API::Solutions::MentorDiscussionsControllerTest < API::BaseTestCase
  guard_incorrect_token! :finish_api_solution_discussion_path, args: 2, method: :patch

  ###
  # Finish
  ###
  test "finishes discussion" do
    freeze_time do
      student = create :user, handle: "student"
      setup_user(student)

      solution = create :concept_solution, user: student
      discussion = create :mentor_discussion, solution: solution

      # Assert we don't do things unless we're asked to
      Mentor::Request::Create.expects(:call).never

      patch finish_api_solution_discussion_path(solution.uuid, discussion), headers: @headers, as: :json

      assert_response 200

      discussion.reload
      assert_equal :finished, discussion.status
      assert_equal :student, discussion.finished_by
      assert_equal Time.current, discussion.finished_at
    end
  end

  test "requeues if required" do
    student = create :user, handle: "student"
    setup_user(student)

    comment_markdown = "Pls help me thanks"

    solution = create :concept_solution, user: student
    original_request = create :mentor_request, solution: solution, comment_markdown: comment_markdown
    original_request.fulfilled!
    discussion = create :mentor_discussion, solution: solution, request: original_request

    patch finish_api_solution_discussion_path(solution.uuid, discussion),
      params: { requeue: true },
      headers: @headers, as: :json
    assert_response 200

    # Sanity
    assert_equal :finished, discussion.reload.status

    solution.reload
    assert_equal 2, solution.mentor_requests.size

    request = solution.mentor_requests.last
    refute_equal original_request.id, request.id
    assert_equal comment_markdown, request.comment_markdown
  end
end
