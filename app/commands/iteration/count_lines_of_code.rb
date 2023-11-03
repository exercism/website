class Iteration::CountLinesOfCode
  include Mandate

  queue_as :solution_processing

  initialize_with :iteration

  def call
    # Sometimes the iteration might be deleted
    # before we get to the job. There *shouldn't* be
    # a DB race condition because of the way this is called
    # in Iteration::Create but if we see missing lines of code,
    # that's probably worth investigating
    return unless iteration

    return unless iteration.submission.valid_filepaths.any?

    # Legacy solutions may never have been pushed to EFS, so check that here.
    iteration.submission.write_to_efs!

    body = RestClient.post(
      Exercism.config.lines_of_code_counter_url,
      {
        track_slug: iteration.track.slug,
        submission_uuid: iteration.submission.uuid,
        submission_filepaths: iteration.submission.valid_filepaths
      }.to_json,
      { content_type: :json, accept: :json }
    ).body

    response = JSON.parse(body)
    num_loc = response["counts"]["code"]

    iteration.update_column(:num_loc, num_loc)
    Solution::UpdateNumLoc.(iteration.solution)
  end
end
