class Test::Components::EditorController < Test::BaseController
  def show; end

  def create_submission
    submission = Submission.create!(
      solution: Solution.first,
      uuid: SecureRandom.compact_uuid,
      major: true,
      submitted_via: "website"
    )

    render json: submission
  end

  def stub_result
    message = case params[:test_status]
              when "Pass"
                {
                  tests_status: "pass",
                  test_runs: [
                    { name: :test_a_name_given, status: :pass, output: "Hello" }
                  ]
                }
              when "Fail"
                {
                  tests_status: "fail",
                  test_runs: [
                    { name: :test_no_name_given, status: :fail }
                  ]
                }
              end

    Test::Submissions::TestRunsChannel.broadcast_to(Submission.last, message)
  end
end
