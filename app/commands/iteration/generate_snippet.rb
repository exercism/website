class Iteration::GenerateSnippet
  include Mandate

  queue_as :solution_processing

  initialize_with :iteration

  def call
    # Sometimes the iteration might be deleted
    # before we get to the job. There *shouldn't* be
    # a DB race condition because of the way this is called
    # in Iteration::Create but if we see missing snippets,
    # that's probably worth investigating
    return unless iteration

    file = iteration.submission.files.first
    return unless file

    # Legacy solutions may never have been pushed to EFS, so check that here.
    iteration.submission.write_to_efs!

    snippet = RestClient.post(
      Exercism.config.snippet_generator_url,
      {
        language: iteration.track.slug,
        source_code: file.content
      }.to_json,
      { content_type: :json, accept: :json }
    ).body

    snippet = "#{snippet[0, 1400]}\n\n..." if snippet.length > 1400

    iteration.update_column(:snippet, snippet)
    Solution::UpdateSnippet.(iteration.solution)
  rescue JSON::GeneratorError => e
    # Silently drop things where we can't parse characters in the resulting JSON.
    # This is going to be down to unicode issues
    return if e.message.include?("Invalid Unicode")

    raise
  end
end
