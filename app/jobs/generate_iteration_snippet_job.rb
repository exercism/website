class GenerateIterationSnippetJob < ApplicationJob
  queue_as :default

  def perform(iteration)
    # TODO: Set this through Exercism config
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
