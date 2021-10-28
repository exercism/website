require "test_helper"

class CalculateLinesOfCodeJobTest < ActiveJob::TestCase
  test "num_loc is updated for iteration" do
    submission = create :submission
    create :submission_file, submission: submission, content: "Some source code"
    iteration = create :iteration, submission: submission

    num_loc = 24
    stub_request(:post, "https://internal.exercism.org/count_lines_of_code").
      with(
        body: {
          track_slug: iteration.track.slug,
          submission_uuid: iteration.submission.uuid,
          submission_filepaths: iteration.submission.valid_filepaths
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

    assert_nil iteration.reload.num_loc
    assert_nil iteration.solution.reload.num_loc
  end

  test "solution is updated if iteration is latest" do
    submission = create :submission
    create :submission_file, submission: submission, content: "Some source code"
    create :iteration, solution: submission.solution
    latest_iteration = create :iteration, submission: submission
    create :iteration, solution: submission.solution, deleted_at: Time.current # Last iteration

    num_loc = 24
    stub_request(:post, "https://internal.exercism.org/count_lines_of_code").
      with(
        body: {
          track_slug: latest_iteration.track.slug,
          submission_uuid: latest_iteration.submission.uuid,
          submission_filepaths: latest_iteration.submission.valid_filepaths
        }.to_json
      ).
      to_return(status: 200, body: "{\"counts\":{\"code\":#{num_loc},\"blanks\":9,\"comments\":0},\"files\":[\"Anagram.fs\"]}", headers: {}) # rubocop:disable Layout/LineLength

    CalculateLinesOfCodeJob.perform_now(latest_iteration)

    assert_equal num_loc, latest_iteration.reload.num_loc
    assert_equal num_loc, latest_iteration.solution.reload.num_loc
  end

  test "solution is not updated if iteration is not latest" do
    submission = create :submission
    create :submission_file, submission: submission, content: "Some source code"
    iteration = create :iteration, submission: submission
    create :iteration, solution: submission.solution

    num_loc = 24
    stub_request(:post, "https://internal.exercism.org/count_lines_of_code").
      with(
        body: {
          track_slug: iteration.track.slug,
          submission_uuid: iteration.submission.uuid,
          submission_filepaths: iteration.submission.valid_filepaths
        }.to_json
      ).
      to_return(status: 200, body: "{\"counts\":{\"code\":#{num_loc},\"blanks\":9,\"comments\":0},\"files\":[\"Anagram.fs\"]}", headers: {}) # rubocop:disable Layout/LineLength

    CalculateLinesOfCodeJob.perform_now(iteration)

    assert_equal num_loc, iteration.reload.num_loc
    assert_nil iteration.solution.reload.num_loc
  end

  test "solution is updated if iteration is published" do
    submission = create :submission
    create :submission_file, submission: submission, content: "Some source code"
    create :iteration, solution: submission.solution
    iteration = create :iteration, submission: submission
    create :iteration, solution: submission.solution
    submission.solution.update(published_iteration: iteration)

    num_loc = 24
    stub_request(:post, "https://internal.exercism.org/count_lines_of_code").
      with(
        body: {
          track_slug: iteration.track.slug,
          submission_uuid: iteration.submission.uuid,
          submission_filepaths: iteration.submission.valid_filepaths
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
    stub_request(:post, "https://internal.exercism.org/count_lines_of_code").
      with(
        body: {
          track_slug: iteration.track.slug,
          submission_uuid: iteration.submission.uuid,
          submission_filepaths: iteration.submission.valid_filepaths
        }.to_json
      ).
      to_return(status: 200, body: "{\"counts\":{\"code\":#{num_loc},\"blanks\":9,\"comments\":0},\"files\":[\"Anagram.fs\"]}", headers: {}) # rubocop:disable Layout/LineLength

    CalculateLinesOfCodeJob.perform_now(iteration)

    assert_equal num_loc, iteration.reload.num_loc
    assert_nil iteration.solution.reload.num_loc
  end
end
