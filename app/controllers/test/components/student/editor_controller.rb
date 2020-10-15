class Test::Components::Student::EditorController < Test::BaseController
  def show
    @solution = Solution.first
  end

  def create_submission
    submission = Submission.create!(
      solution: Solution.first,
      uuid: SecureRandom.compact_uuid,
      major: true,
      submitted_via: "website"
    )

    render json: SerializeSubmission.(submission)
  end

  def stub_test_run_status
    message = case params[:test_run_status]
              when "Pass"
                {
                  submission_uuid: Submission.last.uuid,
                  status: "pass",
                  tests: [
                    { name: :test_a_name_given, status: :pass, output: "Hello" }
                  ],
                  message: ""
                }
              when "Fail"
                {
                  submission_uuid: Submission.last.uuid,
                  status: "fail",
                  tests: [
                    { name: :test_no_name_given, status: :fail }
                  ],
                  message: ""
                }
              when "Error"
                {
                  submission_uuid: Submission.last.uuid,
                  status: "error",
                  tests: [],
                  message: "Undefined local variable"
                }
              when "Ops error"
                {
                  submission_uuid: Submission.last.uuid,
                  status: "ops_error",
                  tests: [],
                  message: "Can't run the tests"
                }
              end

    Test::Submission::TestRunsChannel.broadcast_to(Submission.last, message)
  end
end
