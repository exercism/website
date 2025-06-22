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

    files = submission.valid_files
    return unless files.any?

    # Upload the files to EFS so that the counter can access them
    ToolingJob::UploadToEFS.(efs_dir, files)

    body = RestClient.post(
      Exercism.config.lines_of_code_counter_url,
      {
        track_slug: iteration.track.slug,
        efs_dir:,
        submission_filepaths: filepaths
      }.to_json,
      { content_type: :json, accept: :json }
    ).body

    response = JSON.parse(body)
    num_loc = response["counts"]["code"]

    iteration.update_column(:num_loc, num_loc)
    Solution::UpdateNumLoc.(iteration.solution)
  ensure
    ToolingJob::DeleteFromEFS.(efs_dir)
  end

  private
  delegate :submission, to: :iteration

  memoize
  def job_id = SecureRandom.uuid.tr('-', '')

  memoize
  def files = submission.valid_files

  memoize
  def filepaths = files.map(&:filename)

  memoize
  def efs_dir
    date = Time.current.utc.strftime('%Y/%m/%d')
    "#{Exercism.config.efs_tooling_jobs_mount_point}/#{date}/#{job_id}"
  end
end
