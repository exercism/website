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
          instructions_url:,
          track: {
            id: track.slug,
            language: track.title
          }
        },
        file_download_base_url:,
        files:,
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
    return unless solution.viewable_by?(requester)

    return Exercism::Routes.private_solution_url(solution) if solution.user == requester
    return Exercism::Routes.mentoring_discussion_url(discussion) if requester.mentor? && discussion
    return Exercism::Routes.mentoring_request_url(mentoring_request) if requester.mentor? && mentoring_request

    Exercism::Routes.published_solution_url(solution) if solution.published?
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
    Mentor::Discussion.find_by(mentor: requester, solution:)
  end

  memoize
  def mentoring_request
    Mentor::Request.find_by(solution:, status: :pending)
  end
end
