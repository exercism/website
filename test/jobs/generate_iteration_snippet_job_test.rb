require "test_helper"

class GenerateIterationSnippetJobTest < ActiveJob::TestCase
  setup do
    code = "Some source code"
    @snippet = "Some generated snippet"

    stub_request(:post, "https://internal.exercism.org/extract_snippet").
      with(
        body: "{\"language\":\"ruby\",\"source_code\":\"#{code}\"}"
      ).
      to_return(status: 200, body: @snippet, headers: {})

    @submission = create :submission
    create :submission_file, submission: @submission, content: code
  end

  test "snippet is updated for iteration and solution" do
    iteration = create :iteration, submission: @submission

    GenerateIterationSnippetJob.perform_now(iteration)

    assert_equal @snippet, iteration.reload.snippet
    assert_equal @snippet, iteration.solution.reload.snippet
  end

  test "solution is updated if iteration is latest" do
    create :iteration, solution: @submission.solution
    latest_iteration = create :iteration, submission: @submission
    create :iteration, solution: @submission.solution, deleted_at: Time.current # Last iteration

    GenerateIterationSnippetJob.perform_now(latest_iteration)

    assert_equal @snippet, latest_iteration.reload.snippet
    assert_equal @snippet, latest_iteration.solution.reload.snippet
  end

  test "solution is not updated if iteration is not latest" do
    iteration = create :iteration, submission: @submission
    create :iteration, solution: @submission.solution

    GenerateIterationSnippetJob.perform_now(iteration)

    assert_equal @snippet, iteration.reload.snippet
    assert_nil iteration.solution.reload.snippet
  end

  test "solution is updated if iteration is published" do
    create :iteration, solution: @submission.solution
    iteration = create :iteration, submission: @submission
    create :iteration, solution: @submission.solution
    @submission.solution.update(published_iteration: iteration, published_at: Time.current)

    GenerateIterationSnippetJob.perform_now(iteration)

    assert_equal @snippet, iteration.reload.snippet
    assert_equal @snippet, iteration.solution.reload.snippet
  end

  test "solution is not updated if another iteration is published" do
    older_iteration = create :iteration, solution: @submission.solution
    iteration = create :iteration, submission: @submission
    create :iteration, solution: @submission.solution
    @submission.solution.update(published_iteration: older_iteration)

    GenerateIterationSnippetJob.perform_now(iteration)

    assert_equal @snippet, iteration.reload.snippet
    assert_nil iteration.solution.reload.snippet
  end

  test "silently drop unicode json errors" do
    iteration = create :iteration, submission: @submission

    RestClient.stubs(:post).raises(JSON::GeneratorError, "Invalid Unicode [fa ed fe 07 00]")

    GenerateIterationSnippetJob.perform_now(iteration)
  end

  test "handle long snippets" do
    @snippet << ("x" * 1500)
    iteration = create :iteration, submission: @submission

    GenerateIterationSnippetJob.perform_now(iteration)
    snippet = iteration.reload.snippet
    assert snippet.ends_with?("\n\n...")
    assert_equal 1405, snippet.length
  end
end
