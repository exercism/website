require "test_helper"

class Iteration::CountLinesOfCodeTest < ActiveJob::TestCase
  test "num_loc is updated for iteration" do
    submission = create :submission
    create :submission_file, submission:, content: "Some source code"
    iteration = create(:iteration, submission:)

    num_loc = 24
    stub_request(:post, Exercism.config.lines_of_code_counter_url).
      with(
        body: {
          track_slug: iteration.track.slug,
          submission_uuid: iteration.submission.uuid,
          submission_filepaths: iteration.submission.valid_filepaths
        }.to_json
      ).
      to_return(status: 200, body: "{\"counts\":{\"code\":#{num_loc},\"blanks\":9,\"comments\":0},\"files\":[\"Anagram.fs\"]}", headers: {}) # rubocop:disable Layout/LineLength

    Iteration::CountLinesOfCode.(iteration)

    assert_equal num_loc, iteration.reload.num_loc
    assert_equal num_loc, iteration.solution.reload.num_loc
  end

  test "ignores nil iteration" do
    iteration = nil

    Iteration::CountLinesOfCode.(iteration)
  end

  test "ignores iteration without valid filepaths" do
    submission = create :submission
    iteration = create(:iteration, submission:)

    Iteration::CountLinesOfCode.(iteration)

    assert_nil iteration.reload.num_loc
    assert_nil iteration.solution.reload.num_loc
  end

  test "solution is updated if iteration is latest" do
    submission = create :submission
    create :submission_file, submission:, content: "Some source code"
    create :iteration, solution: submission.solution
    latest_iteration = create(:iteration, submission:)
    create :iteration, solution: submission.solution, deleted_at: Time.current # Last iteration

    num_loc = 24
    stub_request(:post, Exercism.config.lines_of_code_counter_url).
      with(
        body: {
          track_slug: latest_iteration.track.slug,
          submission_uuid: latest_iteration.submission.uuid,
          submission_filepaths: latest_iteration.submission.valid_filepaths
        }.to_json
      ).
      to_return(status: 200, body: "{\"counts\":{\"code\":#{num_loc},\"blanks\":9,\"comments\":0},\"files\":[\"Anagram.fs\"]}", headers: {}) # rubocop:disable Layout/LineLength

    Iteration::CountLinesOfCode.(latest_iteration)

    assert_equal num_loc, latest_iteration.reload.num_loc
    assert_equal num_loc, latest_iteration.solution.reload.num_loc
  end

  test "solution is not updated if iteration is not latest" do
    solution = create :concept_solution
    submission = create(:submission, solution:)
    create :submission_file, submission:, content: "Some source code"
    iteration = create(:iteration, submission:)
    other_iteration = create :iteration, solution:, num_loc: 33
    solution.update(num_loc: other_iteration.num_loc)

    num_loc = 24
    stub_request(:post, Exercism.config.lines_of_code_counter_url).
      with(
        body: {
          track_slug: iteration.track.slug,
          submission_uuid: iteration.submission.uuid,
          submission_filepaths: iteration.submission.valid_filepaths
        }.to_json
      ).
      to_return(status: 200, body: "{\"counts\":{\"code\":#{num_loc},\"blanks\":9,\"comments\":0},\"files\":[\"Anagram.fs\"]}", headers: {}) # rubocop:disable Layout/LineLength

    Iteration::CountLinesOfCode.(iteration)

    assert_equal num_loc, iteration.reload.num_loc
    assert_equal other_iteration.num_loc, solution.reload.num_loc
  end

  test "solution is updated if iteration is published" do
    solution = create :concept_solution, :published
    submission = create(:submission, solution:)
    create :submission_file, submission:, content: "Some source code"
    create(:iteration, solution:)
    iteration = create(:iteration, submission:)
    create(:iteration, solution:)
    solution.update(published_iteration: iteration)

    num_loc = 24
    stub_request(:post, Exercism.config.lines_of_code_counter_url).
      with(
        body: {
          track_slug: iteration.track.slug,
          submission_uuid: iteration.submission.uuid,
          submission_filepaths: iteration.submission.valid_filepaths
        }.to_json
      ).
      to_return(status: 200, body: "{\"counts\":{\"code\":#{num_loc},\"blanks\":9,\"comments\":0},\"files\":[\"Anagram.fs\"]}", headers: {}) # rubocop:disable Layout/LineLength

    Iteration::CountLinesOfCode.(iteration)

    assert_equal num_loc, iteration.reload.num_loc
    assert_equal iteration.num_loc, solution.reload.num_loc
  end

  test "solution is not updated if another iteration is published" do
    solution = create :concept_solution
    submission = create :submission
    create :submission_file, submission:, content: "Some source code"
    published_iteration = create :iteration, solution: submission.solution, num_loc: 33
    iteration = create(:iteration, submission:)
    create :iteration, solution: submission.solution
    solution.update(published_iteration:, num_loc: published_iteration.num_loc)

    num_loc = 24
    stub_request(:post, Exercism.config.lines_of_code_counter_url).
      with(
        body: {
          track_slug: iteration.track.slug,
          submission_uuid: iteration.submission.uuid,
          submission_filepaths: iteration.submission.valid_filepaths
        }.to_json
      ).
      to_return(status: 200, body: "{\"counts\":{\"code\":#{num_loc},\"blanks\":9,\"comments\":0},\"files\":[\"Anagram.fs\"]}", headers: {}) # rubocop:disable Layout/LineLength

    Iteration::CountLinesOfCode.(iteration)

    assert_equal num_loc, iteration.reload.num_loc
    assert_equal published_iteration.num_loc, solution.reload.num_loc
  end
end
