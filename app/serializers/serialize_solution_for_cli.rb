class SerializeSolutionForCLI
  include Mandate

  initialize_with :solution, :requester

  def call
    {
      solution: {
        id: solution.uuid,
        url: solution_url,
        user: {
          handle: user_handle,
          is_requester: solution.user_id == requester.id
        },
        exercise: {
          id: solution.exercise.slug,
          instructions_url: instructions_url,
          track: {
            id: track.slug,
            language: track.title
          }
        },
        file_download_base_url: file_download_base_url,
        files: files,
        submission: submission_hash
      }
    }
  end

  private
  def user_handle
    # Handles can change on anonymous tracks
    user_track = UserTrack.for(solution.user, track)
    if user_track.anonymous_during_mentoring?
      solution.anonymised_user_handle
    else
      solution.user.handle
    end
  end

  def solution_url
    # TODO: Don't let someone download a personal_uuid and
    # end up with the mentor_uuid here. Actively guard this.

    return Exercism::Routes.private_solution_url(solution) if solution.user == requester
    return Exercism::Routes.mentoring_discussion_url(discussion) if requester.mentor? && discussion
    return Exercism::Routes.published_solution_url(solution) if solution.published?
    return Exercism::Routes.published_solution_url(solution) if requester.mentor? && mentor_request_pending?
  end

  def instructions_url
    Exercism::Routes.private_solution_url(solution)
  end

  def file_download_base_url
    "#{Exercism.config.api_host}/v1/solutions/#{solution.uuid}/files/"
  end

  def files
    fs = Set.new
    Git::Exercise.for_solution(solution).cli_filepaths.each do |filepath|
      fs.add(filepath)
    end
    fs += submission.files.pluck(:filename) if submission
    fs
  end

  def submission_hash
    return nil unless submission

    { submitted_at: submission.created_at }
  end

  memoize
  def submission
    solution.submissions.last
  end

  memoize
  def track
    solution.exercise.track
  end

  memoize
  def discussion
    Mentor::Discussion.find_by(mentor: requester, solution: solution)
  end

  memoize
  def mentor_request_pending?
    Mentor::Request.where(solution: solution, status: :pending).exists?
  end
end
