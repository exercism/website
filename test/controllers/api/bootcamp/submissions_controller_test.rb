require_relative '../base_test_case'

class API::Bootcamp::SubmissionsControllerTest < API::BaseTestCase
  test "create: returns 204" do
    status = "fail"
    tests = [
      { slug: "test_1", status: "pass" },
      { slug: "test_2", status: "fail" }
    ]

    readonly_ranges = [
      { 'from': '0', 'to': '4' },
      { 'from': '6', 'to': '11' }
    ]
    test_results = {
      status:,
      tests:
    }
    code = "puts 'hello'"

    freeze_time do
      user = create :user
      solution = create(:bootcamp_solution, user:)
      params = {
        submission: {
          code:,
          test_results:,
          readonly_ranges:
        }
      }

      setup_user(user)
      post api_bootcamp_solution_submissions_url(solution, params), headers: @headers

      submission = Bootcamp::Submission.last

      assert_response :created
      assert_json_response({ submission: { uuid: submission.uuid } })

      assert_equal status.to_sym, submission.status
      assert_equal test_results, submission.test_results
      assert_equal readonly_ranges, submission.readonly_ranges
    end
  end
end
