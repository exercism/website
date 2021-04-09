require "test_helper"

class GenerateIterationSnippetJobTest < ActiveJob::TestCase
  test "badge create is called" do
    code = "Some source code"
    snippet = "Some generated snippet"

    submission = create :submission
    create :submission_file, submission: submission, content: code
    iteration = create :iteration, submission: submission

    stub_request(:post, "https://g7ngvhuv5l.execute-api.eu-west-2.amazonaws.com/production/extract_snippet").
      with(
        body: "{\"language\":\"ruby\",\"source_code\":\"#{code}\"}"
      ).
      to_return(status: 200, body: snippet, headers: {})

    GenerateIterationSnippetJob.perform_now(iteration)

    assert_equal snippet, iteration.reload.snippet
    assert_equal snippet, iteration.solution.reload.snippet
  end
end
