require "test_helper"

class CalculateLinesOfCodeJobTest < ActiveJob::TestCase
  test "num_loc is updated for iteration" do
    submission = create :submission
    create :submission_file, submission: submission, content: "Some source code"
    iteration = create :iteration, submission: submission

    num_loc = 24
    stub_request(:post, "https://xmhj46lgwc.execute-api.eu-west-2.amazonaws.com/production/count_lines_of_code").
      with(
        body: {
          track_slug: iteration.track.slug,
          submission_uuid: iteration.submission.uuid,
          submission_files: iteration.submission.valid_filepaths
        }.to_json
      ).
      to_return(status: 200, body: "{\"counts\":{\"code\":#{num_loc},\"blanks\":9,\"comments\":0},\"files\":[\"Anagram.fs\"]}", headers: {}) # rubocop:disable Layout/LineLength

    CalculateLinesOfCodeJob.perform_now(iteration)

    assert_equal num_loc, iteration.reload.num_loc
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

    assert_equal 0, iteration.reload.num_loc
    assert_equal 0, iteration.solution.reload.num_loc
  end

  test "solution is updated if iteration is last" do
    submission = create :submission
    create :submission_file, submission: submission, content: "Some source code"
    create :iteration, solution: submission.solution
    iteration = create :iteration, submission: submission

    num_loc = 24
    stub_request(:post, "https://xmhj46lgwc.execute-api.eu-west-2.amazonaws.com/production/count_lines_of_code").
      with(
        body: {
          track_slug: iteration.track.slug,
          submission_uuid: iteration.submission.uuid,
          submission_files: iteration.submission.valid_filepaths
        }.to_json
      ).
      to_return(status: 200, body: "{\"counts\":{\"code\":#{num_loc},\"blanks\":9,\"comments\":0},\"files\":[\"Anagram.fs\"]}", headers: {}) # rubocop:disable Layout/LineLength

    CalculateLinesOfCodeJob.perform_now(iteration)

    assert_equal num_loc, iteration.reload.num_loc
    assert_equal num_loc, iteration.solution.reload.num_loc
  end

  test "solution is not updated if iteration is not last" do
    submission = create :submission
    create :submission_file, submission: submission, content: "Some source code"
    iteration = create :iteration, submission: submission
    create :iteration, solution: submission.solution

    num_loc = 24
    stub_request(:post, "https://xmhj46lgwc.execute-api.eu-west-2.amazonaws.com/production/count_lines_of_code").
      with(
        body: {
          track_slug: iteration.track.slug,
          submission_uuid: iteration.submission.uuid,
          submission_files: iteration.submission.valid_filepaths
        }.to_json
      ).
      to_return(status: 200, body: "{\"counts\":{\"code\":#{num_loc},\"blanks\":9,\"comments\":0},\"files\":[\"Anagram.fs\"]}", headers: {}) # rubocop:disable Layout/LineLength

    CalculateLinesOfCodeJob.perform_now(iteration)

    assert_equal num_loc, iteration.reload.num_loc
    assert_equal 0, iteration.solution.reload.num_loc
  end

  test "solution is updated if iteration is published" do
    submission = create :submission
    create :submission_file, submission: submission, content: "Some source code"
    create :iteration, solution: submission.solution
    iteration = create :iteration, submission: submission
    create :iteration, solution: submission.solution
    submission.solution.update(published_iteration: iteration)

    num_loc = 24
    stub_request(:post, "https://xmhj46lgwc.execute-api.eu-west-2.amazonaws.com/production/count_lines_of_code").
      with(
        body: {
          track_slug: iteration.track.slug,
          submission_uuid: iteration.submission.uuid,
          submission_files: iteration.submission.valid_filepaths
        }.to_json
      ).
      to_return(status: 200, body: "{\"counts\":{\"code\":#{num_loc},\"blanks\":9,\"comments\":0},\"files\":[\"Anagram.fs\"]}", headers: {}) # rubocop:disable Layout/LineLength

    CalculateLinesOfCodeJob.perform_now(iteration)

    assert_equal num_loc, iteration.reload.num_loc
    assert_equal num_loc, iteration.solution.reload.num_loc
  end

  test "solution is not updated if another iteration is published" do
    submission = create :submission
    create :submission_file, submission: submission, content: "Some source code"
    older_iteration = create :iteration, solution: submission.solution
    iteration = create :iteration, submission: submission
    create :iteration, solution: submission.solution
    submission.solution.update(published_iteration: older_iteration)

    num_loc = 24
    stub_request(:post, "https://xmhj46lgwc.execute-api.eu-west-2.amazonaws.com/production/count_lines_of_code").
      with(
        body: {
          track_slug: iteration.track.slug,
          submission_uuid: iteration.submission.uuid,
          submission_files: iteration.submission.valid_filepaths
        }.to_json
      ).
      to_return(status: 200, body: "{\"counts\":{\"code\":#{num_loc},\"blanks\":9,\"comments\":0},\"files\":[\"Anagram.fs\"]}", headers: {}) # rubocop:disable Layout/LineLength

    CalculateLinesOfCodeJob.perform_now(iteration)

    assert_equal num_loc, iteration.reload.num_loc
    assert_equal 0, iteration.solution.reload.num_loc
  end
end
