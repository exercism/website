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
    Test::Submissions::TestRunsChannel.broadcast_to(Submission.last, {
                                                      tests_status: "pass",
                                                      test_runs: [
                                                        { name: :test_a_name_given, status: :pass, output: "Hello" }
                                                      ]
                                                    })
  end
end
