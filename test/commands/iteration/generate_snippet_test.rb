require "test_helper"

class Iteration::GenerateSnippetTest < ActiveJob::TestCase
  setup do
    code = "Some source code"
    @snippet = "Some generated snippet"

    stub_request(:post, Exercism.config.snippet_generator_url).
      with(
        body: "{\"language\":\"ruby\",\"source_code\":\"#{code}\"}"
      ).
      to_return(status: 200, body: @snippet, headers: {})

    @submission = create :submission
    create :submission_file, submission: @submission, content: code
  end

  test "snippet is updated for iteration and solution" do
    iteration = create :iteration, submission: @submission

    Iteration::GenerateSnippet.(iteration)

    assert_equal @snippet, iteration.reload.snippet
    assert_equal @snippet, iteration.solution.reload.snippet
  end

  test "solution is updated if iteration is latest" do
    create :iteration, solution: @submission.solution
    latest_iteration = create :iteration, submission: @submission
    create :iteration, solution: @submission.solution, deleted_at: Time.current # Last iteration

    Iteration::GenerateSnippet.(latest_iteration)

    assert_equal @snippet, latest_iteration.reload.snippet
    assert_equal @snippet, latest_iteration.solution.reload.snippet
  end

  test "solution is not updated if iteration is not latest" do
    iteration = create :iteration, submission: @submission
    create :iteration, solution: @submission.solution

    Iteration::GenerateSnippet.(iteration)

    assert_equal @snippet, iteration.reload.snippet
    assert_nil iteration.solution.reload.snippet
  end

  test "solution is updated if iteration is published" do
    create :iteration, solution: @submission.solution
    iteration = create :iteration, submission: @submission
    create :iteration, solution: @submission.solution
    @submission.solution.update(published_iteration: iteration, published_at: Time.current)

    Iteration::GenerateSnippet.(iteration)

    assert_equal @snippet, iteration.reload.snippet
    assert_equal @snippet, iteration.solution.reload.snippet
  end

  test "solution is not updated if another iteration is published" do
    older_iteration = create :iteration, solution: @submission.solution
    iteration = create :iteration, submission: @submission
    create :iteration, solution: @submission.solution
    @submission.solution.update(published_iteration: older_iteration)

    Iteration::GenerateSnippet.(iteration)

    assert_equal @snippet, iteration.reload.snippet
    assert_nil iteration.solution.reload.snippet
  end

  test "silently drop unicode json errors" do
    iteration = create :iteration, submission: @submission

    RestClient.stubs(:post).raises(JSON::GeneratorError, "Invalid Unicode [fa ed fe 07 00]")

    Iteration::GenerateSnippet.(iteration)
  end

  test "requeues on bad gateway" do
    iteration = create :iteration, submission: @submission

    RestClient.stubs(:post).raises(RestClient::BadGateway)

    Iteration::GenerateSnippet.expects(:defer).with do |iter, **kwargs|
      iter == iteration && kwargs[:retries_count] == 1 && kwargs[:wait].between?(30, 90)
    end
    Iteration::GenerateSnippet.(iteration)
  end

  test "requeues on service unavailable" do
    iteration = create :iteration, submission: @submission

    RestClient.stubs(:post).raises(RestClient::ServiceUnavailable)

    Iteration::GenerateSnippet.expects(:defer).with do |iter, **kwargs|
      iter == iteration && kwargs[:retries_count] == 1 && kwargs[:wait].between?(30, 90)
    end
    Iteration::GenerateSnippet.(iteration)
  end

  test "requeues on gateway timeout" do
    iteration = create :iteration, submission: @submission

    RestClient.stubs(:post).raises(RestClient::GatewayTimeout)

    Iteration::GenerateSnippet.expects(:defer).with do |iter, **kwargs|
      iter == iteration && kwargs[:retries_count] == 1 && kwargs[:wait].between?(30, 90)
    end
    Iteration::GenerateSnippet.(iteration)
  end

  test "raises after max retries exhausted" do
    iteration = create :iteration, submission: @submission

    RestClient.stubs(:post).raises(RestClient::BadGateway)

    assert_raises Iteration::GenerateSnippet::SnippetGeneratorTemporarilyUnavailable do
      Iteration::GenerateSnippet.(iteration, retries_count: 3)
    end
  end

  test "handle long snippets" do
    code = "Some source code"
    snippet = "Some generated snippet#{"x" * 1500}"

    stub_request(:post, Exercism.config.snippet_generator_url).
      with(
        body: "{\"language\":\"ruby\",\"source_code\":\"#{code}\"}"
      ).
      to_return(status: 200, body: snippet, headers: {})

    iteration = create :iteration, submission: @submission

    Iteration::GenerateSnippet.(iteration)
    snippet = iteration.reload.snippet
    assert snippet.ends_with?("\n\n...")
    assert_equal 1405, snippet.length
  end

  test "sends the exercise's main solution file when there are several files" do
    Git::Exercise.any_instance.stubs(solution_filepaths: ["foobar.cpp", "foobar.h"])
    create :submission_file, submission: @submission, filename: "foobar.h", content: "header"
    create :submission_file, submission: @submission, filename: "foobar.cpp", content: "implementation"
    iteration = create :iteration, submission: @submission

    stub_request(:post, Exercism.config.snippet_generator_url).
      with(body: "{\"language\":\"ruby\",\"source_code\":\"implementation\"}").
      to_return(status: 200, body: "main snippet", headers: {})

    Iteration::GenerateSnippet.(iteration)

    assert_equal "main snippet", iteration.reload.snippet
  end

  test "matches the main solution file when its filename starts with ./" do
    Git::Exercise.any_instance.stubs(solution_filepaths: ["src/lib.rs"])
    create :submission_file, submission: @submission, filename: "src/helper.rs", content: "helper"
    create :submission_file, submission: @submission, filename: "./src/lib.rs", content: "library"
    iteration = create :iteration, submission: @submission

    stub_request(:post, Exercism.config.snippet_generator_url).
      with(body: "{\"language\":\"ruby\",\"source_code\":\"library\"}").
      to_return(status: 200, body: "lib snippet", headers: {})

    Iteration::GenerateSnippet.(iteration)

    assert_equal "lib snippet", iteration.reload.snippet
  end

  test "sends only the first 20,000 characters of a long file" do
    long_code = "é" * 25_000
    submission = create :submission
    create :submission_file, submission: submission, content: long_code
    iteration = create :iteration, submission: submission

    stub = stub_request(:post, Exercism.config.snippet_generator_url).
      with { |request| JSON.parse(request.body)["source_code"] == "é" * 20_000 }.
      to_return(status: 200, body: "truncated snippet", headers: {})

    Iteration::GenerateSnippet.(iteration)

    assert_requested stub
    assert_equal "truncated snippet", iteration.reload.snippet
  end
end
