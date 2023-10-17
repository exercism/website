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

  test "handle long snippets" do
    @snippet << ("x" * 1500)
    iteration = create :iteration, submission: @submission

    Iteration::GenerateSnippet.(iteration)
    snippet = iteration.reload.snippet
    assert snippet.ends_with?("\n\n...")
    assert_equal 1405, snippet.length
  end
end
