require "test_helper"

class CalculateLinesOfCodeJobTest < ActiveJob::TestCase
  test "num_loc is updated for iteration" do
    code = "Some source code"
    submission = create :submission
    create :submission_file, submission: submission, content: code
    iteration = create :iteration, submission: submission
    num_loc = 24

    stub_request(:post, "https://g7ngvhuv5l.execute-api.eu-west-2.amazonaws.com/production/count_lines_of_code").
      with(
        body: {
          track_slug: iteration.track.slug,
          submission_uuid: iteration.uuid,
          submission_files: iteration.submission.valid_filepaths
        }.to_json
      ).
      to_return(status: 200, body: "{\"code\":#{num_loc},\"blanks\":9,\"comments\":0,\"files\":[\"Anagram.fs\"]}", headers: {})

    CalculateLinesOfCodeJob.perform_now(iteration)

    assert_equal num_loc, iteration.solution.reload.num_loc
  end

  test "ignores nil iteration" do
    iteration = nil

    CalculateLinesOfCodeJob.perform_now(iteration)
  end

  test "ignores iteration without valid filepaths" do
    submission = create :submission
    iteration = create :iteration, submission: submission

    CalculateLinesOfCodeJob.perform_now(iteration)

    assert_equal 0, iteration.solution.reload.num_loc
  end
end
