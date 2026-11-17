require "test_helper"

class Iteration::CountLinesOfCodeTest < ActiveJob::TestCase
  test "num_loc is updated for iteration" do
    submission = create :submission
    create :submission_file, submission:, content: "Some source code"
    iteration = create(:iteration, submission:)

    create(:submission_file, submission:, filename: "other.rb", content: "More code")

    num_loc = 24
    stub_request(:post, Exercism.config.lines_of_code_counter_url).
      with(
        body: {
          track_slug: iteration.track.slug,
          files: iteration.submission.valid_files.to_h { |f| [f.filename, f.content] }
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
      to_return(status: 200, body: "{\"counts\":{\"code\":#{num_loc},\"blanks\":9,\"comments\":0},\"files\":[\"Anagram.fs\"]}", headers: {}) # rubocop:disable Layout/LineLength

    Iteration::CountLinesOfCode.(iteration)

    assert_equal num_loc, iteration.reload.num_loc
    assert_equal iteration.num_loc, solution.reload.num_loc
  end

  test "sends file contents as a hash of filename to content" do
    submission = create :submission
    create :submission_file, submission:, filename: "lib/bob.rb", content: "puts 'héllo'"
    iteration = create(:iteration, submission:)

    stub = stub_request(:post, Exercism.config.lines_of_code_counter_url).
      with(body: { track_slug: iteration.track.slug, files: { "lib/bob.rb" => "puts 'héllo'" } }.to_json).
      to_return(status: 200, body: '{"counts":{"code":1}}')

    Iteration::CountLinesOfCode.(iteration)

    assert_requested stub
    assert_equal 1, iteration.reload.num_loc
  end

  test "skips files that are not valid UTF-8" do
    submission = create :submission
    create :submission_file, submission:, filename: "good.rb", content: "puts 1"
    create :submission_file, submission:, filename: "bad.rb", content: "puts \xFF".b
    iteration = create(:iteration, submission:)

    stub = stub_request(:post, Exercism.config.lines_of_code_counter_url).
      with(body: { track_slug: iteration.track.slug, files: { "good.rb" => "puts 1" } }.to_json).
      to_return(status: 200, body: '{"counts":{"code":1}}')

    Iteration::CountLinesOfCode.(iteration)

    assert_requested stub
  end

  test "does not post if no files are valid UTF-8" do
    submission = create :submission
    create :submission_file, submission:, filename: "bad.rb", content: "puts \xFF".b
    iteration = create(:iteration, submission:)

    Iteration::CountLinesOfCode.(iteration)

    assert_nil iteration.reload.num_loc
  end

  test "does not post if the request body is over the size limit" do
    submission = create :submission
    create :submission_file, submission:, filename: "big.rb", content: "a" * Iteration::CountLinesOfCode::MAX_BODY_BYTES
    iteration = create(:iteration, submission:)

    RestClient.expects(:post).never
    Iteration::CountLinesOfCode.(iteration)

    assert_nil iteration.reload.num_loc
  end

  test "requeues on service unavailable and gateway timeout" do
    [RestClient::ServiceUnavailable, RestClient::GatewayTimeout].each do |error|
      submission = create :submission
      create :submission_file, submission:, content: "Some source code"
      iteration = create(:iteration, submission:)

      RestClient.stubs(:post).raises(error)
      Iteration::CountLinesOfCode.expects(:defer).with { |iter, **kw| iter == iteration && kw[:retries_count] == 1 }
      Iteration::CountLinesOfCode.(iteration)
    end
  end

  test "requeues on bad gateway" do
    submission = create :submission
    create :submission_file, submission:, content: "Some source code"
    iteration = create(:iteration, submission:)

    RestClient.stubs(:post).raises(RestClient::BadGateway)

    Iteration::CountLinesOfCode.expects(:defer).with do |iter, **kwargs|
      iter == iteration && kwargs[:retries_count] == 1 && kwargs[:wait].between?(30, 90)
    end
    Iteration::CountLinesOfCode.(iteration)
  end

  test "raises after max retries exhausted" do
    submission = create :submission
    create :submission_file, submission:, content: "Some source code"
    iteration = create(:iteration, submission:)

    RestClient.stubs(:post).raises(RestClient::BadGateway)

    assert_raises Iteration::CountLinesOfCode::LocCounterTemporarilyUnavailable do
      Iteration::CountLinesOfCode.(iteration, retries_count: 3)
    end
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
    stub_request(:post, Exercism.config.lines_of_code_counter_url).to_return(status: 200, body: "{\"counts\":{\"code\":#{num_loc},\"blanks\":9,\"comments\":0},\"files\":[\"Anagram.fs\"]}", headers: {}) # rubocop:disable Layout/LineLength

    Iteration::CountLinesOfCode.(iteration)

    assert_equal num_loc, iteration.reload.num_loc
    assert_equal published_iteration.num_loc, solution.reload.num_loc
  end
end
