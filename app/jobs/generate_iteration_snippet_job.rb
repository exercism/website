class GenerateIterationSnippetJob < ApplicationJob
  queue_as :snippets

  def perform(iteration)
    # Sometimes the iteration might be deleted
    # before we get to the job. There *shouldn't* be
    # a DB race condition because of the way this is called
    # in Iteration::Create but if we see missing snippets,
    # that's probably worth investigating
    return unless iteration

    # TODO: (Required) Set this through Exercism config
    url = "https://g7ngvhuv5l.execute-api.eu-west-2.amazonaws.com/production/extract_snippet"
    snippet = RestClient.post(
      url,
      {
        language: iteration.track.slug,
        source_code: iteration.submission.files.first.content
      }.to_json,
      { content_type: :json, accept: :json }
    ).body

    iteration.update_column(:snippet, snippet)

    # TODO: Think about how we want to handle solution snippets
    iteration.solution.update_column(:snippet, snippet) if iteration.solution.iterations.last == iteration
  end
end
