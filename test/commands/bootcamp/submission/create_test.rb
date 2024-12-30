require 'test_helper'

class Bootcamp::Submission::CreateTest < ActiveSupport::TestCase
  test "creates a submission" do
    solution = create :bootcamp_solution
    code = "puts 'hello'"
    test_results = {
      status: "fail",
      tests: [
        test_1: 'pass',
        test_2: 'fail'
      ]
    }
    readonly_ranges = [{ from: '0', to: '4' }, { from: '6', to: '11' }]

    submission = Bootcamp::Submission::Create.(solution, code, test_results, readonly_ranges)

    assert_equal solution, submission.solution
    assert_equal code, submission.code
    assert_equal test_results, submission.test_results
    assert_equal readonly_ranges, submission.readonly_ranges
  end

  test "fail fails" do
    submission = Bootcamp::Submission::Create.(
      create(:bootcamp_solution), "",
      {
        status: "fail", tests: []
      },
      []
    )

    assert_equal :fail, submission.status
  end

  test "pass passes" do
    submission = Bootcamp::Submission::Create.(
      create(:bootcamp_solution), "",
      {
        status: "pass", tests: []
      },
      []
    )

    assert_equal :pass, submission.status
  end
end
