class Iteration::GenerateSnippet
  include Mandate

  queue_as :solution_processing

  initialize_with :iteration, retries_count: 0

  MAX_RETRIES = 3
  # The extractor Lambda times out after 3 seconds, which very large files can
  # hit. The snippet only uses the first lines, so we send just the start.
  MAX_SOURCE_CODE_CHARACTERS = 20_000
  SnippetGeneratorTemporarilyUnavailable = Class.new(StandardError)

  def call
    # Sometimes the iteration might be deleted
    # before we get to the job. There *shouldn't* be
    # a DB race condition because of the way this is called
    # in Iteration::Create but if we see missing snippets,
    # that's probably worth investigating
    return unless iteration

    file = main_file
    return unless file

    snippet = RestClient.post(
      Exercism.config.snippet_generator_url,
      {
        language: iteration.track.slug,
        source_code: file.content[0, MAX_SOURCE_CODE_CHARACTERS]
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
  rescue RestClient::BadGateway, RestClient::ServiceUnavailable, RestClient::GatewayTimeout
    # This error is manually ignored on Sentry unless it escalates
    raise SnippetGeneratorTemporarilyUnavailable if retries_count >= MAX_RETRIES

    self.class.defer(iteration, retries_count: retries_count + 1, wait: rand(30..90))
  end

  private
  # The first submitted file named in the exercise's solution files, in the
  # order of that list (tracks list the implementation before any header).
  # Falls back to the first file saved.
  def main_file
    files = iteration.submission.files.to_a
    solution_filepaths = iteration.submission.exercise_repo.solution_filepaths

    solution_filepaths.each do |path|
      file = files.find { |f| f.filename.delete_prefix("./") == path }
      return file if file
    end

    files.first
  end
end
