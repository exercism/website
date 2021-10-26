class CalculateLinesOfCodeJob < ApplicationJob
  extend Mandate::Memoize

  queue_as :snippets

  def perform(iteration)
    # Sometimes the iteration might be deleted
    # before we get to the job. There *shouldn't* be
    # a DB race condition because of the way this is called
    # in Iteration::Create but if we see missing lines of code,
    # that's probably worth investigating
    return unless iteration

    return unless iteration.submission.valid_filepaths.any?

    # TODO: (Required) Set this through Exercism config
    url = "https://g7ngvhuv5l.execute-api.eu-west-2.amazonaws.com/production/count_lines_of_code"
    body = RestClient.post(
      url,
      {
        track_slug: iteration.track.slug,
        submission_uuid: iteration.uuid,
        submission_files: iteration.submission.valid_filepaths
      }.to_json,
      { content_type: :json, accept: :json }
    ).body
    response = JSON.parse(body)
    iteration.solution.update_column(:num_loc, response["counts"]["code"])
  end
end
