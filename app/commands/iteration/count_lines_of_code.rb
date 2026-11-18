class Iteration::CountLinesOfCode
  include Mandate

  queue_as :solution_processing

  initialize_with :iteration, retries_count: 0

  MAX_RETRIES = 3

  # The counter runs as a Lambda behind an ALB, which rejects
  # request bodies over 1 MB with a 413.
  MAX_BODY_BYTES = 1_000_000
  LocCounterTemporarilyUnavailable = Class.new(StandardError)

  def call
    # Sometimes the iteration might be deleted
    # before we get to the job. There *shouldn't* be
    # a DB race condition because of the way this is called
    # in Iteration::Create but if we see missing lines of code,
    # that's probably worth investigating
    return unless iteration

    return if files.empty?

    request_body = { track_slug: iteration.track.slug, files: }.to_json
    return if request_body.bytesize > MAX_BODY_BYTES

    body = RestClient.post(
      Exercism.config.lines_of_code_counter_url,
      request_body,
      { content_type: :json, accept: :json }
    ).body

    response = JSON.parse(body)
    num_loc = response["counts"]["code"]

    iteration.update_column(:num_loc, num_loc)
    Solution::UpdateNumLoc.(iteration.solution)
  rescue RestClient::BadGateway, RestClient::ServiceUnavailable, RestClient::GatewayTimeout
    # This error is manually ignored on Sentry unless it escalates
    raise LocCounterTemporarilyUnavailable if retries_count >= MAX_RETRIES

    self.class.defer(iteration, retries_count: retries_count + 1, wait: rand(30..90))
  end

  private
  delegate :submission, to: :iteration

  # A hash of filename => content for each valid file. Files whose content
  # isn't valid UTF-8 are left out, as they can't be sent as JSON strings
  # and would otherwise be counted as a placeholder line.
  memoize
  def files
    submission.valid_files.
      select { |file| file.utf8_content.valid_encoding? }.
      to_h { |file| [file.filename, file.content] }
  end
end
